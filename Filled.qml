import QtQuick 2.0

Column {
    id: root
    spacing: -1
    property var cells: []
    property var size: ({ width: 10, height: 10 })

    function setSize(width, height) {
        root.size = {width: width, height: height}
        root.cells = []
        for (let i = 0; i < columnRepeater.count; ++i) {
            const rowChildren = columnRepeater.itemAt(i).children
            const indexRepeater = rowChildren.length - 1
            const rowRepeater = rowChildren[indexRepeater]
            for (let a = 0; a < rowRepeater.count; ++a) {
                root.cells.push(rowRepeater.itemAt(a))
            }
        }
    }
    function clearAll() {
        root.clearCells()
        for (let i = 0; i < root.cells.length; ++i) {
            root.cells[i].reset_m_id_source()
        }
    }
    function clearCells() {
        for (let i = 0; i < root.cells.length; ++i) {
            root.cells[i].clear()
        }
    }
    function reset_m_id_sourceById(id) {
        for (let i = 0; i < root.cells.length; ++i) {
            if (root.cells[i].m_id_source === id) {
                root.cells[i].reset_m_id_source()
            }
        }
    }

    function findCells(items) {
        const findedCells = []
        for(let i = 0; i < items.length; ++i) {
            const puzzle = items[i]; const puzzlePoint = {x: puzzle.width / 2, y: puzzle.height / 2}
            const cells = root.cells
            for (let a = 0; a < cells.length; ++a) {
                const point = cells[a].mapToItem(puzzle, puzzlePoint.x , puzzlePoint.y )
                if (cells[a].contains(point)) {
                    findedCells.push(cells[a])
                    break
                }
            }
        }

        return findedCells
    }

    Repeater {
        id: columnRepeater
        model: root.size.height
        Row {
            id: row
            spacing: -1
            Repeater {
                id: rowRepeater
                model: root.size.width
                Rectangle {
                    id: figs
                    property int m_id_source: -1
                    width: 20
                    height: 20
                    color: {
                        if (okCell) {
                            return '#039BE5'
                        }

                        if (warningCell) {
                            return '#F44336'
                        }
                        return '#90A4AE'
                    }

                    border.width: 1
                    property bool okCell: false
                    property bool warningCell: false

                    function clear() {
                        okCell = false
                        warningCell = false
                    }
                    function reset_m_id_source() {
                        m_id_source = -1
                    }
                    function set_m_id_source(id) {
                        m_id_source = id
                    }
                    //если фигуру можно расположить
                    function setOkCell(ok) {
                        figs.okCell = ok
                    }
                    //если нельзя расположить
                    function setWarningCell(ok) {
                        figs.warningCell = ok
                    }
                    function getPointFromField() {
                        return {x: figs.x, y: row.y}
                    }
                }
            }
        }
    }

    Component.onCompleted: {
        setSize(root.size.width, root.size.height)
    }
}
