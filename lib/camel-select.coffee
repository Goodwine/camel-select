# Copyright 2016 Google Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

{CompositeDisposable, Point} = require 'atom'

module.exports = CamelSelect =
  config:
    stopSymbols:
      type: 'string'
      default: atom.config.get("editor").nonWordCharacters + '_'
    spaceAsBoundaryCharacters:
      type: 'boolean'
      default: false

  direction:
    RIGHT: 1
    LEFT: -1

  action:
    MOVE: 1
    SELECT: 2
    DELETE: 3

  mode:
    BOUNDARY: 1
    SPAAAACE: 2
    NEUTRAL: 3
    LOWER: 4
    UPPER: 5

  boundaryChars: {}
  subscriptions: null
  spaceAsBoundary: false

  activate: ->
    @subscriptions = new CompositeDisposable

    boundaryChars = atom.config.get("camel-select").stopSymbols
    @boundaryChars[ch] = true for ch in boundaryChars.split ''

    @spaceAsBoundary = atom.config.get("camel-select").spaceAsBoundaryCharacters

    @subscriptions.add atom.commands.add 'atom-workspace',
      'camel-select:move-to-end-of-subword': =>
        @doAction @direction.RIGHT, @action.MOVE

      'camel-select:move-to-beginning-of-subword': =>
        @doAction @direction.LEFT, @action.MOVE

      'camel-select:select-to-end-of-subword': =>
        @doAction @direction.RIGHT, @action.SELECT

      'camel-select:select-to-beginning-of-subword': =>
        @doAction @direction.LEFT, @action.SELECT

      'camel-select:remove-to-end-of-subword': =>
        @doAction @direction.RIGHT, @action.DELETE

      'camel-select:remove-to-beginning-of-subword': =>
        @doAction @direction.LEFT, @action.DELETE

  deactivate: ->
    @subscriptions.dispose()

  doAction: (dir, action) ->
    editor = atom.workspace.getActiveTextEditor()
    return unless editor

    sel = editor.getSelections()
    buffer = editor.getBuffer()
    for c, i in editor.getCursors()
      @singleCursorAction buffer, c, sel[i], dir, action

  singleCursorAction: (buffer, c, sel, dir, action) ->
    pos = c.getBufferPosition()
    nextPos = @findNextPos buffer, c, pos, dir

    return if nextPos.compare(pos) is 0

    if action is @action.MOVE
      c.setBufferPosition nextPos
    else
      sel.selectToBufferPosition nextPos
      sel.delete() if action is @action.DELETE

  findNextPos: (buffer, c, pos, dir) ->
    line = c.getCurrentBufferLine()
    mode = null
    row = pos.row
    i = pos.column

    loop
      # Get index for the character to work with instead of the cursor position.
      chi = if dir is @direction.RIGHT then i else i - 1

      if chi >= line.length
        # Stop at a new line or when out of boundaries when going RIGHT.
        return new Point(row, line.length) if row is buffer.getLastRow() or mode
        # Skip empty lines when we start at the end of a row.
        while buffer.isRowBlank ++row
          continue
        row = Math.min row, buffer.getLastRow()
        return new Point(row, 0)
      else if chi < 0
        # Stop at a new line or when out of boundaries when going LEFT.
        return new Point(row, 0) if row is 0 or mode
        # Skip empty lines when we start at the beginning of a row.
        while buffer.isRowBlank --row
          continue
        row = Math.max row, 0
        return new Point(row, buffer.lineForRow(row).length)

      # Some rules need to return a position that is inclusive or exclusive, but
      # these values need to be normalized to a "cursor index".
      exclusive = if dir is @direction.RIGHT then chi else chi + 1
      inclusive = if dir is @direction.LEFT then chi else chi + 1

      nextMode = @modeFor line[chi]
      mode = nextMode unless mode

      decision = @makeDecision mode, nextMode, inclusive, exclusive, dir
      return new Point(row, decision.stopAt) if decision.stopAt?

      mode = decision.mode
      i += dir

  modeFor: (ch) ->
    return @mode.BOUNDARY if @boundaryChars[ch]
    if /\s/.test ch
      return if @spaceAsBoundary then @mode.SPAAAACE else @mode.BOUNDARY
    lower = ch.toLowerCase()
    return @mode.NEUTRAL if lower is ch.toUpperCase()
    return @mode.LOWER if lower is ch
    return @mode.UPPER

  makeDecision: (mode, nextMode, inclusive, exclusive, dir) ->
    return {mode: mode} if mode is nextMode

    # The following lines imply the current and next modes are different.
    # These lines are in the same order as the README.md file describes its
    # rules.

    # Handle going to or coming from boundary characters
    return {mode: nextMode} if mode is @mode.BOUNDARY
    return {stopAt: exclusive} if nextMode is @mode.BOUNDARY

    # Handle going to or coming from space characters
    return {mode: nextMode} if mode is @mode.SPAAAACE
    return {stopAt: exclusive} if nextMode is @mode.SPAAAACE

    # Handle going to or coming from "neutral" characters
    return {mode: nextMode} if mode is @mode.NEUTRAL
    return {mode: mode} if nextMode is @mode.NEUTRAL

    # When lower chars meet upper chars
    if mode is @mode.LOWER
      return {stopAt: inclusive} if dir is @direction.LEFT
      return {stopAt: exclusive}
    else
      # By elimination, mode is @mode.UPPER and nextMode is @mode.LOWER
      return {stopAt: exclusive} if dir is @direction.LEFT
      return {mode: nextMode}
