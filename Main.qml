import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import SddmComponents 2.0 as SDDM

Rectangle {
    id: root
    width: config.autoDetectResolution ? Screen.width : 1920
    height: config.autoDetectResolution ? Screen.height : 1080
    
    // Access to SDDM API
    SDDM.TextConstants { id: textConstants }
    
    // Theme properties
    readonly property bool isLightTheme: config.themeMode === "light" || 
                                        (config.themeMode === "auto" && 
                                         Qt.colorEqual(backgroundColor, Qt.lighter(backgroundColor)))
    
    readonly property color primaryColor: isLightTheme ? 
                                        config.lightThemePrimaryColor : 
                                        config.darkThemePrimaryColor
                                        
    readonly property color backgroundColor: isLightTheme ? 
                                           config.lightThemeBackgroundColor : 
                                           config.darkThemeBackgroundColor
    
    readonly property color textColor: isLightTheme ? Qt.darker(backgroundColor, 4.5) : Qt.lighter(backgroundColor, 4.5)
    readonly property color accentColor: config.accentColor
    
    // Performance properties
    readonly property bool useBlur: !config.disableBlur && !config.lowPerformanceMode
    readonly property bool useAnimations: !config.reduceAnimations
    readonly property real animationDuration: useAnimations ? 300 * config.animationSpeed : 0
    
    // Background
    color: config.backgroundColour

    // Background Image
    Image {
        id: backgroundImage
        anchors.fill: parent
        source: config.backgroundMode === "image" ? config.wallpaper : ""
        fillMode: config.fitWallpaper ? Image.PreserveAspectFit : Image.PreserveAspectCrop
        visible: config.backgroundMode === "image"
        
        // Simple blur alternative - we add a semi-transparent overlay instead
    }
    
    // Darken layer for better readability
    Rectangle {
        id: darkenLayer
        anchors.fill: parent
        color: "black"
        opacity: 0.4
    }
    
    // Clock widget
    Item {
        id: clockWidget
        anchors.centerIn: config.clockPosition === "center" ? parent : undefined
        anchors.right: config.clockPosition === "right" ? parent.right : undefined
        anchors.left: config.clockPosition === "left" ? parent.left : undefined
        anchors.top: config.clockPosition.includes("top") ? parent.top : undefined
        anchors.bottom: config.clockPosition.includes("bottom") ? parent.bottom : undefined
        anchors.margins: 40
        
        width: clockText.width
        height: clockText.height + (config.showDate ? dateText.height + 10 : 0)
        
        Text {
            id: clockText
            anchors.horizontalCenter: parent.horizontalCenter
            
            color: textColor
            font.family: config.fontFamily
            font.pointSize: config.fontSize * 4
            font.weight: config.fontWeight
            
            text: {
                var date = new Date();
                var hours = date.getHours();
                
                if (!config.use24HourFormat && hours > 12) {
                    hours -= 12;
                }
                
                var minutes = date.getMinutes();
                var seconds = date.getSeconds();
                var timeString = hours.toString().padStart(2, "0") + ":" + 
                                minutes.toString().padStart(2, "0");
                
                if (config.showSeconds) {
                    timeString += ":" + seconds.toString().padStart(2, "0");
                }
                
                if (!config.use24HourFormat) {
                    timeString += hours >= 12 ? " PM" : " AM";
                }
                
                return timeString;
            }
            
            Timer {
                interval: 1000
                running: true
                repeat: true
                onTriggered: parent.text = parent.text
            }
        }
        
        Text {
            id: dateText
            anchors.top: clockText.bottom
            anchors.topMargin: 10
            anchors.horizontalCenter: parent.horizontalCenter
            
            visible: config.showDate
            color: textColor
            font.family: config.fontFamily
            font.pointSize: config.fontSize * 1.5
            font.weight: config.fontWeight
            
            text: {
                var date = new Date();
                return date.toLocaleDateString(Qt.locale(), config.dateFormat);
            }
        }
    }
    
    // Login form
    Rectangle {
        id: loginForm
        width: 400
        height: 480
        radius: config.roundedCorners ? 10 : 0
        color: backgroundColor
        opacity: config.formTransparency
        
        anchors.centerIn: parent
        
        // Shadow effect using nested rectangles instead of DropShadow
        Rectangle {
            id: shadowEffect
            anchors.fill: parent
            anchors.margins: -8
            radius: parent.radius + 8
            color: "black"
            opacity: 0.3
            z: -1
            visible: config.roundedCorners
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 15

            // Logo/welcome area
            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 120
                
                Image {
                    id: logo
                    anchors.centerIn: parent
                    width: 100
                    height: 100
                    source: "components/icons/logo.png"
                    fillMode: Image.PreserveAspectFit
                    visible: false
                }
                
                Rectangle {
                    id: avatarBackground
                    anchors.centerIn: parent
                    width: 100
                    height: 100
                    radius: config.avatarShape === "circle" ? width / 2 : (config.roundedCorners ? 10 : 0)
                    color: accentColor
                    visible: !logo.visible
                    
                    Text {
                        anchors.centerIn: parent
                        text: "👤"
                        font.pointSize: 40
                        color: "white"
                    }
                }
            }
            
            // User selection combo box
            ComboBox {
                id: userBox
                visible: config.showUserList && !config.disableUserList
                Layout.fillWidth: true
                model: userModel
                currentIndex: userModel.lastIndex
                textRole: "name"
                
                delegate: ItemDelegate {
                    width: userBox.width
                    text: config.hideUserNames ? "User " + (index + 1) : name
                    highlighted: userBox.highlightedIndex === index
                }
                
                onCurrentIndexChanged: {
                    if (currentIndex >= 0) {
                        userNameInput.text = config.hideUserNames ? "" : userModel.data(userModel.index(currentIndex, 0), Qt.UserRole + 1)
                    }
                }
            }
            
            // Username field
            TextField {
                id: userNameInput
                Layout.fillWidth: true
                text: config.showLastUser && userModel.lastUser ? userModel.lastUser : ""
                placeholderText: config.usernamePlaceholder || textConstants.userName
                visible: !config.showUserList || config.disableUserList
                
                onAccepted: {
                    passwordInput.forceActiveFocus()
                }
            }
            
            // Password field
            TextField {
                id: passwordInput
                Layout.fillWidth: true
                placeholderText: config.passwordPlaceholder || textConstants.password
                echoMode: config.passwordEchoMode === "masked" ? TextInput.Password : 
                          (config.hidePasswordLength ? TextInput.NoEcho : TextInput.Password)
                
                Keys.onEnterPressed: startLogin()
                Keys.onReturnPressed: startLogin()
            }
            
            // Warning message
            Label {
                id: errorMessage
                Layout.fillWidth: true
                color: "red"
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
                visible: false
            }
            
            // Login button
            Button {
                id: loginButton
                Layout.fillWidth: true
                text: config.loginButtonText || textConstants.login
                visible: config.showLoginButton
                
                background: Rectangle {
                    radius: config.roundedCorners ? 5 : 0
                    color: loginButton.down ? Qt.darker(accentColor, 1.3) : 
                          (loginButton.hovered ? Qt.lighter(accentColor, 1.1) : accentColor)
                }
                
                contentItem: Text {
                    text: loginButton.text
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                
                onClicked: startLogin()
            }
            
            // Session selection
            RowLayout {
                Layout.fillWidth: true
                spacing: 10
                
                Label {
                    text: textConstants.session
                    color: textColor
                }
                
                ComboBox {
                    id: sessionBox
                    Layout.fillWidth: true
                    model: sessionModel
                    currentIndex: sessionModel.lastIndex
                    textRole: "name"
                }
            }
            
            // Keyboard layout
            RowLayout {
                Layout.fillWidth: true
                spacing: 10
                visible: keyboard.layouts.length > 1
                
                Label {
                    text: textConstants.layout
                    color: textColor
                }
                
                ComboBox {
                    id: layoutBox
                    Layout.fillWidth: true
                    model: keyboard.layouts
                    currentIndex: keyboard.currentLayout
                    
                    onCurrentIndexChanged: {
                        keyboard.currentLayout = currentIndex
                    }
                }
            }
            
            Item {
                Layout.fillHeight: true
            }
        }
    }
    
    // Power menu
    Row {
        id: powerControls
        anchors.bottom: parent.bottom
        anchors.right: config.powerButtonsPosition.includes("right") ? parent.right : undefined
        anchors.left: config.powerButtonsPosition.includes("left") ? parent.left : undefined
        anchors.horizontalCenter: config.powerButtonsPosition.includes("center") ? parent.horizontalCenter : undefined
        anchors.margins: 20
        spacing: 10
        visible: config.showPowerButtons
        
        function createPowerButton(iconText, actionText, visible, action) {
            if (!visible) return null;
            
            var button = powerButtonComponent.createObject(powerControls, {
                "iconText": iconText,
                "actionText": actionText,
                "action": action
            });
            
            return button;
        }
        
        Component {
            id: powerButtonComponent
            
            Rectangle {
                id: powerButton
                width: 50
                height: 50
                radius: config.roundedCorners ? width / 2 : 0
                color: mouseArea.containsMouse ? Qt.lighter(backgroundColor, 1.5) : backgroundColor
                opacity: 0.7
                
                property string iconText
                property string actionText
                property var action
                
                // Add simple shadow using nested rectangle
                Rectangle {
                    anchors.fill: parent
                    anchors.margins: -2
                    radius: parent.radius + 2
                    color: "black"
                    opacity: 0.2
                    z: -1
                    visible: config.roundedCorners
                }
                
                Text {
                    anchors.centerIn: parent
                    text: parent.iconText
                    color: textColor
                    font.pointSize: 16
                }
                
                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: parent.action()
                }
                
                // Basic tooltip replacement
                Rectangle {
                    id: tooltip
                    visible: mouseArea.containsMouse
                    opacity: mouseArea.containsMouse ? 1.0 : 0.0
                    color: Qt.darker(backgroundColor, 1.2)
                    radius: 3
                    height: tooltipText.contentHeight + 10
                    width: tooltipText.contentWidth + 20
                    x: parent.width / 2 - width / 2
                    y: -height - 5
                    
                    Behavior on opacity {
                        NumberAnimation { duration: 200 }
                    }
                    
                    Text {
                        id: tooltipText
                        anchors.centerIn: parent
                        text: parent.parent.actionText
                        color: textColor
                    }
                }
            }
        }
        
        Component.onCompleted: {
            if (config.shutdownEnabled)
                createPowerButton("⏻", textConstants.shutdown, true, function() { 
                    sddm.powerOff(); 
                });
                
            if (config.restartEnabled)
                createPowerButton("⭮", textConstants.reboot, true, function() { 
                    sddm.reboot(); 
                });
                
            if (config.suspendEnabled)
                createPowerButton("⏾", textConstants.suspend, true, function() { 
                    sddm.suspend(); 
                });
                
            if (config.hibernateEnabled)
                createPowerButton("⏴", textConstants.hibernate, true, function() { 
                    sddm.hibernate(); 
                });
        }
    }
    
    // Accessibility button
    Rectangle {
        id: accessibilityButton
        width: 50
        height: 50
        radius: config.roundedCorners ? width / 2 : 0
        color: mouseArea.containsMouse ? Qt.lighter(backgroundColor, 1.5) : backgroundColor
        opacity: 0.7
        
        // Simple shadow
        Rectangle {
            anchors.fill: parent
            anchors.margins: -2
            radius: parent.radius + 2
            color: "black"
            opacity: 0.2
            z: -1
            visible: config.roundedCorners
        }
        
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.margins: 20
        
        Text {
            anchors.centerIn: parent
            text: "♿"
            color: textColor
            font.pointSize: 16
        }
        
        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            onClicked: accessibilityMenu.visible = !accessibilityMenu.visible
        }
        
        Rectangle {
            id: accessibilityMenu
            width: 240
            height: 200
            radius: config.roundedCorners ? 10 : 0
            color: backgroundColor
            opacity: 0.9
            visible: false
            
            // Simple shadow
            Rectangle {
                anchors.fill: parent
                anchors.margins: -3
                radius: parent.radius + 3
                color: "black"
                opacity: 0.3
                z: -1
                visible: config.roundedCorners
            }
            
            anchors.bottom: parent.top
            anchors.bottomMargin: 10
            
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 15
                spacing: 10
                
                CheckBox {
                    text: "High Contrast"
                    checked: config.highContrastMode
                    onCheckedChanged: {
                        // Would be implemented to adjust contrast
                    }
                }
                
                CheckBox {
                    text: "Large Text"
                    checked: config.largePrintMode
                    onCheckedChanged: {
                        // Would be implemented to adjust text size
                    }
                }
                
                CheckBox {
                    text: "Virtual Keyboard"
                    checked: config.virtualKeyboard
                    onCheckedChanged: {
                        // Would be implemented to show virtual keyboard
                    }
                }
                
                CheckBox {
                    text: "Reduce Animations"
                    checked: config.reduceAnimations
                    onCheckedChanged: {
                        // Would be implemented to reduce animations
                    }
                }
            }
        }
    }
    
    // Network status indicator
    Rectangle {
        id: networkStatus
        width: 20
        height: 20
        radius: width / 2
        color: "green" // Would be connected/disconnected status
        opacity: 0.7
        
        // Simple shadow
        Rectangle {
            anchors.fill: parent
            anchors.margins: -1
            radius: parent.radius + 1
            color: "black"
            opacity: 0.2
            z: -1
        }
        
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 20
        visible: config.enableNetworkCheck
        
        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            
            // Simple tooltip
            Rectangle {
                id: networkTooltip
                visible: parent.containsMouse
                opacity: parent.containsMouse ? 1.0 : 0.0
                color: Qt.darker(backgroundColor, 1.2)
                radius: 3
                height: networkTooltipText.contentHeight + 10
                width: networkTooltipText.contentWidth + 20
                x: -width - 5
                y: parent.height / 2 - height / 2
                
                Behavior on opacity {
                    NumberAnimation { duration: 200 }
                }
                
                Text {
                    id: networkTooltipText
                    anchors.centerIn: parent
                    text: "Network Connected" // Would be dynamic
                    color: textColor
                }
            }
        }
    }
    
    // Login function
    function startLogin() {
        var username = config.showUserList && !config.disableUserList ? 
                      userModel.data(userModel.index(userBox.currentIndex, 0), Qt.UserRole + 1) : 
                      userNameInput.text;
                      
        if (username === "") {
            errorMessage.text = textConstants.prompt.split("%1").join("")
            errorMessage.visible = true
            return
        }
        
        if (passwordInput.text === "" && !config.allowEmptyPassword) {
            errorMessage.text = textConstants.promptPassword
            errorMessage.visible = true
            return
        }
        
        errorMessage.visible = false
        sddm.login(username, passwordInput.text, sessionBox.currentIndex)
    }
    
    // Login failed hook
    Connections {
        target: sddm
        
        function onLoginFailed() {
            passwordInput.text = ""
            passwordInput.focus = true
            errorMessage.text = textConstants.loginFailed
            errorMessage.visible = true
            
            // Implement login attempt tracking here
        }
    }
    
    Component.onCompleted: {
        if (config.autoFocusPassword && !config.showUserList) {
            passwordInput.forceActiveFocus()
        }
    }
}
