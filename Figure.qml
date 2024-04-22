import QtQuick 2.0
import QtQuick.Controls 2.0
import Slice 1.0

Control {
    id: root
    implicitWidth: column.implicitWidth
    implicitHeight: column.implicitHeight

    property var figure

    property int m_id: figure.m_id
    property var points: figure.points
    property var puzzleObject: figure.puzzleItems
    transform: Rotation {
            origin.x: root.implicitWidth / 2; origin.y: root.implicitHeight / 2
            angle: figure.rotation
        }

    focusPolicy: Qt.StrongFocus

    z: mouseArea.drag.active ? 10 : 1

    signal positionChanged(var mouse)
    signal pressed(var mouse)
    signal released(var mouse)
    Keys.onPressed: FigureSlice.keysPressed(event, root.m_id)
    onPressed: FigureSlice.pressed(root.m_id)
    onPositionChanged: FigureSlice.positionChanged(root.m_id)
    onReleased: FigureSlice.released(fig)

    function changePosition(x, y) {
        root.x = x; root.y = y
    }

    contentItem: Column {
        id: column
        spacing: -1
        property bool dragActive: false
        Repeater {
            model: root.points.length
            Row {
                id: row
                property int columnIndex: index
                spacing: -1
                Repeater {
                    id: repeater
                    model: root.points[row.columnIndex].length
                    Rectangle {
                        id: puzzle
                        color: '#00C853'
                        border.width: 1
                        visible: root.points[row.columnIndex][index]
                        width: 20
                        height: 20
                    }
                }
            }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        onPressed: {
            root.pressed(mouse)
            root.focus = true
        }
        onPositionChanged: root.positionChanged(mouse)
        onReleased: root.released(mouse)

        drag.target: parent
        drag.filterChildren: true
        drag.smoothed: true
        drag.minimumX: 0; drag.maximumX: root.parent.width - root.width
        drag.minimumY: 0; drag.maximumY: root.parent.height - root.height
    }

    Component.onCompleted:  {
        const pushArr = []
        const indexRepeater = column.children.length - 1
        const columnRepeater = column.children[indexRepeater]
        for (let i = 0; i < columnRepeater.count; ++i) {
            const row = columnRepeater.itemAt(i)
            const indexRepeater = row.children.length - 1
            const rowRepeater = row.children[indexRepeater]
            for (let a = 0; a < rowRepeater.count; ++a) {
                if (rowRepeater.itemAt(a).visible) {
                    pushArr.push(rowRepeater.itemAt(a))
                }
            }
        }

        FigureSlice.puzzleItemsPush(root.m_id, pushArr)
    }
}
