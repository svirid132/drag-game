pragma Singleton
import QtQuick 2.0
import 'qrc:/'

Item {
    id: root

    //внешнее
    property Filled filled: null

    //внутрнее
    //Для каждой фигуры набор пазлов. Например: [ [puzzle_1, puzzle_2, ...], [puzzle_1, puzzle_2, ...] ] - две фигуры с разным количеством пазлов
    //Puzzle представляет собой item
    property var figures: []
    property bool finish: false

    function createFigures(figures) {
        const figs = []
        root.finish = false
        figures.forEach((figure, index) => {
                                  let obj = figureComp.createObject(root, {m_id: index, points: figure})
                                  figs.push(obj)
                              })
        root.figures = figs
    }

    Component {
        id: figureComp
        QtObject {
            property int m_id: 0
            property var points: [[1, 0], [1, 0], [1, 1], [1, 1]]//расположение фигруы
            property var puzzleItems: [] //пазлы фигуры
            property int rotation: 0
            property bool setted: false
        }
    }

    Component {
        id: itemComp
        Item {}
    }

    //Добавление пазлов фигуры
    function puzzleItemsPush(id, arr) {
        for (let i = 0; i < root.figures.length; ++i) {
            const figure = root.figures[i]
            if (figure.m_id === id) {
                figure.puzzleItems = arr
            }
        }
    }

    //Обработка нажатия клавиатуры, когда фокус на фигуре
    function keysPressed(event, id) {
        const figure = root.figures.find((fig) => fig.m_id === id)
        if (event.key === Qt.Key_Space) {
            figure.rotation += 90
        }
        filled.clearCells()
        const puzzleItems = figure.puzzleItems
        filled.findCells(puzzleItems)
    }

    //Нажали на фигуру
    function pressed(id) {
        const figure = root.figures.find((fig) => fig.m_id === id)
        figure.setted = false
        filled.reset_m_id_sourceById(id)
    }

    //Обработка изменеия расположения фигуры через drag
    function positionChanged(id) {
        filled.clearCells()
        const figure = root.figures.find((fig) => fig.m_id === id)
        const puzzleItems = figure.puzzleItems
        const findedCells = filled.findCells(puzzleItems)
        const filledCells = findedCells.reduce((val, cell) => cell.m_id_source !== -1 || val, false)
        //puzzleItems.length => length в данном случае показывает сколько кубиков пазла
        if (findedCells.length === puzzleItems.length && !filledCells) {
            for (let i = 0; i < findedCells.length; ++i) {
                findedCells[i].setOkCell(true)
            }
        } else {
            for (let i = 0; i < findedCells.length; ++i) {
                findedCells[i].setWarningCell(true)
            }
        }
    }

    //обработка отпуская левой кнопки мыши
    function released(fig) {
        filled.clearCells()
        const figure = root.figures.find((val) => val.m_id === fig.m_id)
        const findedCells = filled.findCells(figure.puzzleItems)
        const filledCells = findedCells.reduce((val, cell) => cell.m_id_source !== -1 || val, false)
        if (findedCells.length === figure.puzzleItems.length && !filledCells) {
            figure.setted = true
            for (let i = 0; i < findedCells.length; ++i) {
                findedCells[i].set_m_id_source(fig.m_id)
            }
            const point = findedCells.reduce( (p, cell) => {
                                                 const point = cell.getPointFromField()
                                                 return ({
                                                             x: p.x < point.x ? p.x : point.x,
                                                             y: p.y < point.y ? p.y : point.y
                                                         })

                                             }, {x: 5000, y: 5000})
            let offsetX = 0; let offsetY = 0
            if (figure.rotation % 180 === 90) {
                offsetX = fig.height / 2 - fig.width / 2
                offsetY = fig.width / 2 - fig.height / 2
            }
            let obj = itemComp.createObject(fig.parent, {x: fig.x, y: fig.y})
            const p = filled.mapToItem(obj, point.x, point.y)
            fig.changePosition(p.x + fig.x + offsetX, p.y + fig.y + offsetY)
        }
        root.finish = isFinish()
    }

    function isFinish() {
        const finish = figures.reduce((total, val) => total && val.setted, true)
        return finish
    }

}
