/*
 * SPDX-License-Identifier: GPL-3.0-only
 * MuseScore-CLA-applies
 *
 * MuseScore
 * Music Composition & Notation
 *
 * Copyright (C) 2021 MuseScore BVBA and others
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 3 as
 * published by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */
import QtQuick 2.15
import QtQuick.Controls 2.15

import MuseScore.Ui 1.0
import MuseScore.UiComponents 1.0
import MuseScore.Dock 1.0
import MuseScore.AppShell 1.0

import MuseScore.NotationScene 1.0
import MuseScore.Palette 1.0
import MuseScore.Inspector 1.0
import MuseScore.InstrumentsScene 1.0
import MuseScore.Playback 1.0

import "../dockwindow"

DockPage {
    id: root

    objectName: "Notation"
    uri: "musescore://notation"

    property var topToolKeyNavSec

    property NotationPageModel pageModel: NotationPageModel {}

    property NavigationSection noteInputKeyNavSec: NavigationSection {
        id: keynavSec
        name: "NoteInputSection"
        order: 2
    }

    property NavigationSection keynavTopPanelSec: NavigationSection {
        name: "NavigationTopPanel"
        enabled: root.visible
        order: 3
    }

    property NavigationSection keynavLeftPanelSec: NavigationSection {
        name: "NavigationLeftPanel"
        enabled: root.visible
        order: 4
    }

    property NavigationSection keynavRightPanelSec: NavigationSection {
        name: "NavigationRightPanel"
        enabled: root.visible
        order: 6
    }

    property NavigationSection keynavBottomPanelSec: NavigationSection {
        name: "NavigationBottomPanel"
        enabled: root.visible
        order: 7
    }

    function navigationPanelSec(location) {
        switch(location) {
        case Location.Top: return keynavTopPanelSec
        case Location.Left: return keynavLeftPanelSec
        case Location.Right: return keynavRightPanelSec
        case Location.Bottom: return keynavBottomPanelSec
        }

        return null
    }

    onInited: {
        Qt.callLater(pageModel.init)
    }

    readonly property int verticalPanelDefaultWidth: 300

    readonly property var verticalPanelDropDestinations: [
        { "dock": root.centralDock, "dropLocation": Location.Left, "dropDistance": root.verticalPanelDefaultWidth },
        { "dock": root.centralDock, "dropLocation": Location.Right, "dropDistance": root.verticalPanelDefaultWidth }
    ]

    readonly property var horizontalPanelDropDestinations: [
        root.panelTopDropDestination,
        root.panelBottomDropDestination
    ]

    mainToolBars: [
        DockToolBar {
            id: notationToolBar

            objectName: "notationToolBar"
            title: qsTrc("appshell", "Notation toolbar")

            floatable: false
            resizable: false
            separatorsVisible: false
            alignment: DockToolBarAlignment.Center
            contentBottomPadding: 2

            NotationToolBar {
                navigation.section: root.topToolKeyNavSec
                navigation.order: 2

                onActiveFocusRequested: {
                    if (navigation.active) {
                        notationToolBar.forceActiveFocus()
                    }
                }
            }
        },

        DockToolBar {
            id: playbackToolBar

            objectName: pageModel.playbackToolBarName()
            title: qsTrc("appshell", "Playback controls")

            separatorsVisible: false
            alignment: DockToolBarAlignment.Right

            contentBottomPadding: floating ? 8 : 2
            contentTopPadding: floating ? 8 : 0

            dropDestinations: [
                { "dock": notationToolBar, "dropLocation": Location.Right }
            ]

            PlaybackToolBar {
                navigation.section: root.topToolKeyNavSec
                navigation.order: 3

                floating: playbackToolBar.floating
            }
        },

        DockToolBar {
            objectName: pageModel.undoRedoToolBarName()
            title: qsTrc("appshell", "Undo/redo toolbar")

            floatable: false
            resizable: false
            separatorsVisible: false
            alignment: DockToolBarAlignment.Right
            contentBottomPadding: 2

            UndoRedoToolBar {
                navigation.section: root.topToolKeyNavSec
                navigation.order: 4
            }
        }
    ]

    toolBars: [
        DockToolBar {
            id: noteInputBar

            objectName: pageModel.noteInputBarName()
            title: qsTrc("appshell", "Note input")

            dropDestinations: [
                root.toolBarTopDropDestination,
                root.toolBarBottomDropDestination,
                root.toolBarLeftDropDestination,
                root.toolBarRightDropDestination
            ]

            NoteInputBar {
                orientation: noteInputBar.orientation
                floating: noteInputBar.floating

                maximumWidth: noteInputBar.width
                maximumHeight: noteInputBar.height

                navigation.section: root.noteInputKeyNavSec
                navigation.order: 1
            }
        }
    ]

    panels: [
        DockPanel {
            id: palettesPanel

            objectName: pageModel.palettesPanelName()
            title: qsTrc("appshell", "Palettes")

            navigationSection: root.navigationPanelSec(palettesPanel.location)

            width: root.verticalPanelDefaultWidth
            minimumWidth: root.verticalPanelDefaultWidth
            maximumWidth: root.verticalPanelDefaultWidth

            tabifyPanel: instrumentsPanel

            dropDestinations: root.verticalPanelDropDestinations

            PalettesPanel {
                navigationSection: palettesPanel.navigationSection
            }
        },

        DockPanel {
            id: instrumentsPanel

            objectName: pageModel.instrumentsPanelName()
            title: qsTrc("appshell", "Instruments")

            navigationSection: root.navigationPanelSec(instrumentsPanel.location)

            width: root.verticalPanelDefaultWidth
            minimumWidth: root.verticalPanelDefaultWidth
            maximumWidth: root.verticalPanelDefaultWidth

            tabifyPanel: inspectorPanel

            dropDestinations: root.verticalPanelDropDestinations

            InstrumentsPanel {
                navigationSection: instrumentsPanel.navigationSection

                Component.onCompleted: {
                    instrumentsPanel.contextMenuModel = contextMenuModel
                }
            }
        },

        DockPanel {
            id: inspectorPanel

            objectName: pageModel.inspectorPanelName()
            title: qsTrc("appshell", "Properties")

            navigationSection: root.navigationPanelSec(inspectorPanel.location)

            width: root.verticalPanelDefaultWidth
            minimumWidth: root.verticalPanelDefaultWidth
            maximumWidth: root.verticalPanelDefaultWidth
            
            tabifyPanel: selectionFilterPanel

            dropDestinations: root.verticalPanelDropDestinations

            InspectorForm {
                navigationSection: inspectorPanel.navigationSection
            }
        },

        DockPanel {
            id: selectionFilterPanel

            objectName: pageModel.selectionFiltersPanelName()
            title: qsTrc("appshell", "Selection Filter")

            navigationSection: root.navigationPanelSec(selectionFilterPanel.location)

            width: root.verticalPanelDefaultWidth
            minimumWidth: root.verticalPanelDefaultWidth
            maximumWidth: root.verticalPanelDefaultWidth

            //! NOTE: hidden by default
            visible: false

            dropDestinations: root.verticalPanelDropDestinations

            SelectionFilterPanel {
                navigationSection: selectionFilterPanel.navigationSection
            }
        },
        
        // =============================================
        // Horizontal Panels
        // =============================================

        DockPanel {
            id: mixerPanel

            objectName: pageModel.mixerPanelName()
            title: qsTrc("appshell", "Mixer")

            height: minimumHeight
            minimumHeight: 260
            maximumHeight: 520

            tabifyPanel: pianoRollPanel

            //! NOTE: hidden by default
            visible: false

            location: Location.Bottom

            dropDestinations: root.horizontalPanelDropDestinations

            navigationSection: root.navigationPanelSec(mixerPanel.location)

            MixerPanel {
                navigationSection: mixerPanel.navigationSection

                Component.onCompleted: {
                    mixerPanel.contextMenuModel = contextMenuModel
                }
            }
        },

        DockPanel {
            id: pianoRollPanel

            objectName: pageModel.pianoPanelName()
            title: qsTrc("appshell", "Piano Roll")

            height: 200
            minimumHeight: 100
            maximumHeight: 300

            tabifyPanel: timelinePanel

            //! NOTE: hidden by default
            visible: false

            location: Location.Bottom

            dropDestinations: root.horizontalPanelDropDestinations

            StyledTextLabel {
                anchors.centerIn: parent
                text: pianoRollPanel.title
            }
        },

        DockPanel {
            id: timelinePanel

            objectName: pageModel.timelinePanelName()
            title: qsTrc("appshell", "Timeline")

            height: 200
            minimumHeight: 100
            maximumHeight: 300

            //! NOTE: hidden by default
            visible: false

            location: Location.Bottom

            dropDestinations: root.horizontalPanelDropDestinations

            Timeline {}
        },

        DockPanel {
            id: drumsetPanel

            objectName: pageModel.drumsetPanelName()
            title: qsTrc("appshell", "Drumset Tools")

            minimumHeight: 30
            maximumHeight: 30

            location: Location.Bottom

            DrumsetPanel {}
        }
    ]

    central: NotationView {
        id: notationView
        name: "MainNotationView"

        isNavigatorVisible: pageModel.isNavigatorVisible
    }

    statusBar: DockStatusBar {
        objectName: pageModel.statusBarName()

        NotationStatusBar {}
    }
}
