/*
 * Copyright (C) 2020 ~ 2020 Uniontech Technology Co., Ltd.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.11
import QtQuick.Controls 2.4
import QtQuick.Controls.impl 2.4
import QtQuick.Templates 2.4 as T
import QtGraphicalEffects 1.0
import org.deepin.dtk 1.0 as D
import "PixelMetric.js" as PM

T.Button {
    id: control

    implicitWidth: Math.max(background ? background.implicitWidth : 0,
                            contentItem.implicitWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(background ? background.implicitHeight : 0,
                             Math.max(contentItem.implicitHeight, indicator ? indicator.implicitHeight : 0) + topPadding + bottomPadding)

    padding: PM.ControlPadding
    spacing: PM.ControlSpacing

    property alias radius:  backgroundRect.radius
    property string iconName: ""
    property color textColor: palette.buttonText
    property color initGradTopColor: palette.light
    property color initGradBottomColor: palette.dark

    contentItem: IconLabel {
        spacing: control.spacing
        mirrored: control.mirrored
        display: control.display

        icon: control.icon
        text: control.text
        font: control.font
        color: textColor
    }

    background: Item {
        implicitWidth: control.text.length ? PM.Button_MiniSize + (4 * PM.ControlRadius) : PM.Button_MiniSize + (2 * PM.ControlRadius)
        implicitHeight: PM.Button_MiniSize

        DropShadow {
            anchors.fill: backgroundRect
            horizontalOffset: 0
            verticalOffset: 4
            radius: 4
            samples: 9
            color: palette.shadow
            source: backgroundRect
        }

        Rectangle {
            id: backgroundRect
            property color gradTopColor: initGradTopColor
            property color gradBottomColor: initGradBottomColor

            anchors.fill: parent
            radius: PM.ControlRadius
            color: control.palette.button
            gradient: Gradient {
                GradientStop {
                    position: 0
                    color: {
                        // TODO(Chen Bin): Use a c++ or js function instead.
                        if (flat)
                            return "transparent"

                        var buttonColorTop = initGradTopColor;
                        if (highlighted)
                            buttonColorTop = palette.highlight

                        if (down || checked) {
                            var hightColor = palette.highlight;
                            hightColor.a = 0.1;

                            buttonColorTop = D.DTK.adjustColor(buttonColorTop, 0, 0, -20, 0, 0, +20, 0);
                            buttonColorTop = D.DTK.blendColor(buttonColorTop, hightColor);

                            return buttonColorTop
                        }

                        if (hovered) {
                            buttonColorTop = D.DTK.adjustColor(buttonColorTop, 0, 0, -10, 0, 0, 0, 0);

                            return buttonColorTop
                        }

                        return buttonColorTop
                    }
                }
                GradientStop {
                    position: 0.96
                    color: {
                        // TODO(Chen Bin): Use a c++ or js function instead.
                        if (flat)
                            return "transparent"

                        var buttonColorBottom = initGradBottomColor;
                        if (highlighted)
                            buttonColorBottom = palette.highlight

                        if (down || checked) {
                            var hightColor = palette.highlight;
                            hightColor.a = 0.1;

                            buttonColorBottom = D.DTK.adjustColor(buttonColorBottom, 0, 0, -15, 0, 0, +20, 0);
                            buttonColorBottom = D.DTK.blendColor(buttonColorBottom, hightColor);

                            return buttonColorBottom
                        }

                        if (hovered) {
                            buttonColorBottom = D.DTK.adjustColor(buttonColorBottom, 0, 0, -10, 0, 0, 0, 0);

                            return buttonColorBottom
                        }

                        return buttonColorBottom
                    }
                }
            }
        }

        D.CicleSpreadAnimation {
            id: hoverAnimation
            hoverColor: backgroundRect.gradBottomColor
            source: control
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true

            onEntered: {
                hoverAnimation.centerPoint = Qt.point(mouseArea.mouseX, mouseArea.mouseY)
                hoverAnimation.start()
            }

            onExited: {
                hoverAnimation.stop()
            }

            onClicked: mouse.accepted = false;
            onPressed: mouse.accepted = false;
            onReleased: mouse.accepted = false;
            onDoubleClicked: mouse.accepted = false;
            onPositionChanged: mouse.accepted = false;
            onPressAndHold: mouse.accepted = false;
            onWheel: mouse.accepted = false;
        }
    }

    D.Icon {
        id: icon
        anchors.centerIn: parent
        name: iconName
    }
}
