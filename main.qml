import QtQuick 2.15
import QtQuick.Window 2.15
import "qrc:/slice"
import Slice 1.0
import Utils 1.0

Window {
    id: window
    width: 640
    height: 480
    visible: true
    title: qsTr("drag-game")
    minimumHeight: 480; maximumHeight: 480
    minimumWidth: 640; maximumWidth: 640
    x: Screen.virtualX + Screen.width / 2  - width / 2
    y: Screen.virtualY + Screen.height / 2 - height / 2

    Item {
        id: root
        width: window.width
        height: window.height

        File {
            id: file
            path: ":/assets/Levels.json"
            property var jsonData: JSON.parse(readingData)
            Component.onCompleted: {
                read()
            }
        }

        ListView {
            id: listView
            width: 70
            height: root.height
            onCurrentIndexChanged: {
                const level = listView.model[currentIndex].level
                const levelObj = file.jsonData[level]
                filled.clearAll()
                FigureSlice.createFigures(levelObj.figures)
                filled.setSize(levelObj.filled_size.width, levelObj.filled_size.height)
            }

            model: {
                const model = []
                for (const val in file.jsonData) {
                    const obj = { "level": val }
                    model.push(obj)
                }

                return model
            }
            delegate: Rectangle {
                implicitWidth: 70
                implicitHeight: 40
                color: index === listView.currentIndex ? '#039BE5' : '#BDBDBD'
                Text {
                    anchors.centerIn: parent
                    text: listView.model[index].level
                    color: index === listView.currentIndex ? '#FAFAFA' : '#37474F'
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        listView.currentIndex = index
                    }
                }
            }
        }

        Item {
            id: game
            width: root.width - listView.width
            height: root.height
            anchors.left: listView.right
            Repeater {
                id: repeater
                model: FigureSlice.figures
                onModelChanged: settingFigures()
                function settingFigures() {
                    for (let i = 0; i < repeater.count; ++i) {
                        const fig = repeater.itemAt(i)
                        fig.installY(i)
                    }
                }

                Figure {
                    id: fig
                    x: 30
                    property real beginY: -1
                    y: 0
                    figure: modelData

                    property var installY: function(ind) {
                        if (index === 0) {
                            fig.y = 30
                            return
                        }

                        const figure = repeater.itemAt(ind - 1)
                        fig.y = figure.y + figure.height + 30
                    }
                }

                Component.onCompleted: settingFigures()
            }

            Item {
                id: filledWrapper
                anchors.horizontalCenter: game.horizontalCenter
                y: game.height / 2 - implicitHeight / 2 - text.height
                implicitWidth: text.width > filled.width ? text.width : filled.width
                implicitHeight: text.implicitHeight + filled.implicitHeight
                Text {
                    id: text
                    text: FigureSlice.finish ? 'Собрал(а)' : ''
                    anchors.horizontalCenter: filledWrapper.horizontalCenter
                }
                Filled {
                    id: filled
                    anchors.top: text.bottom
                    anchors.horizontalCenter: filledWrapper.horizontalCenter
                    anchors.topMargin: 10
                    Component.onCompleted: {
                        FigureSlice.filled = filled
                    }
                }
            }
        }
    }
}
