import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui

Item {
  id: root

  property string backgroundPath: ""
  property int backgroundVersion: 0
  property bool fingerprintConfigured: false
  property bool authenticatingPassword: false
  property string failureMessage: ""
  property int failedAttempts: 0
  property bool inputEnabled: true
  property bool loadBackground: true
  property string passwordText: ""
  property bool syncingPasswordText: false

  // --- Personal styling, carried over from the old hyprlock.conf -----------
  // Follows the system font: Style.font.family resolves the `monospace`
  // fontconfig alias that `omarchy font set` rewrites, so changing the system
  // font restyles the lock screen too.
  readonly property string labelFont: Style.font.family
  readonly property color labelColor: "#bff2f3f4"   // rgba(242, 243, 244, 0.75)
  readonly property color innerColor: "#b0404040"   // $inner_color
  readonly property string userLabel: "0xHouss"
  readonly property string greetingLabel: "Welcome back!"
  // Assets live beside this file, so the plugin folder is self-contained and
  // survives being moved or restowed. Qt.resolvedUrl() gives a file:// URL;
  // the Process below needs a plain path, hence the prefix strip.
  readonly property string pluginDir: String(Qt.resolvedUrl(".")).replace(/^file:\/\//, "")
  readonly property url avatarUrl: Qt.resolvedUrl("pfp.png")
  readonly property string batteryScript: pluginDir + "battery-status"

  property string clockText: ""
  property string dateText: ""
  property string batteryText: ""

  // The old hyprlock offsets were authored against a 1080px-tall surface. This
  // display is 1920x1080 at scale 1.6, so the lock surface is only 675 logical
  // pixels tall and those offsets would land off-screen. Scaling by the ratio
  // reproduces the original layout at its original *physical* size, on any
  // monitor.
  readonly property real designHeight: 1080
  readonly property real uiScale: height > 0 ? height / designHeight : 1
  function scaled(value) { return Math.round(value * root.uiScale) }

  readonly property string placeholderText: "Enter Password"
  readonly property int fieldWidth: 381
  readonly property int fieldHeight: 67
  readonly property int outlineThickness: 3
  readonly property int fieldFontSize: Math.round(Style.font.heading * 1.125)
  readonly property int passwordDotFontSize: Math.round(Style.font.heading * 1.33)
  readonly property int passwordDotLetterSpacing: Math.round(Style.font.heading * 0.19)
  // Space to keep clear on each side of the field for the fingerprint icon
  // (icon width plus a gap) so the centered dots never run under it.
  readonly property real fingerprintReserve: fingerprintConfigured ? Math.round(fingerprintIcon.implicitWidth + 12) : 0
  // Shrink the dots to fit once the password outgrows the field, so every
  // keystroke stays visible — otherwise long passwords clip with no feedback.
  readonly property real passwordDotScale: dotMetrics.advanceWidth > 0
    ? Math.min(1, (passwordInput.width - 4) / dotMetrics.advanceWidth)
    : 1
  readonly property bool showPasswordCursor: inputEnabled && !authenticatingPassword && failureMessage.length === 0
  readonly property bool errorState: failureMessage.length > 0
  readonly property var inputBorderSpec: errorState
    ? Border.surfaceSpec("lock", "border-error", Color.lock.borderError, root.outlineThickness, "border-alpha")
    : Border.surfaceSpec("lock", "border-active", Color.lock.borderActive, root.outlineThickness, "border-alpha")

  signal submitPassword(string password)
  signal passwordTextEdited(string password)
  signal clearFailureRequested()
  signal wakeRequested()

  // Cache-busts the lock background by appending `?v=`. Adding a query
  // string keeps Image's loader happy while forcing it to reload when the
  // user picks a new background mid-session.
  function fileUrl(path) {
    if (!path) return ""
    var encoded = String(path).split("/").map(encodeURIComponent).join("/")
    return "file://" + encoded + "?v=" + backgroundVersion
  }

  function forcePasswordFocus() {
    passwordInput.forceActiveFocus()
  }

  function clearPassword() {
    passwordTextEdited("")
  }

  function syncPasswordText() {
    if (passwordInput.text === passwordText) return
    syncingPasswordText = true
    passwordInput.text = passwordText
    syncingPasswordText = false
  }

  // %A, %B %d and %k:%M from the old hyprlock labels.
  function updateClock() {
    var now = new Date()
    root.dateText = Qt.formatDateTime(now, "dddd, MMMM dd")
    root.clockText = Qt.formatDateTime(now, "H:mm")
  }

  function refreshBattery() {
    if (!batteryProcess.running) batteryProcess.running = true
  }

  onPasswordTextChanged: syncPasswordText()
  onInputEnabledChanged: {
    if (inputEnabled) Qt.callLater(forcePasswordFocus)
  }
  Component.onCompleted: {
    syncPasswordText()
    updateClock()
    refreshBattery()
    if (inputEnabled) Qt.callLater(forcePasswordFocus)
  }

  Timer {
    id: clockTimer
    interval: 1000
    repeat: true
    running: true
    onTriggered: root.updateClock()
  }

  Timer {
    id: batteryTimer
    interval: 30000
    repeat: true
    running: true
    onTriggered: root.refreshBattery()
  }

  Process {
    id: batteryProcess
    command: ["bash", "-lc", root.batteryScript]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: root.batteryText = String(text || "").trim()
    }
  }

  // Measures the masked password at full size; passwordDotScale compares this
  // against the field width to decide how far the dots must shrink to fit.
  TextMetrics {
    id: dotMetrics
    font.family: Style.font.family
    font.pixelSize: root.passwordDotFontSize
    font.letterSpacing: root.passwordDotLetterSpacing
    text: "●".repeat(passwordInput.text.length)
  }

  Rectangle {
    anchors.fill: parent
    color: Color.background

    Image {
      id: wallpaper
      anchors.fill: parent
      source: root.loadBackground ? root.fileUrl(root.backgroundPath) : ""
      fillMode: Image.PreserveAspectCrop
      asynchronous: true
      cache: false
      sourceSize.width: width
      sourceSize.height: height
    }

    MultiEffect {
      anchors.fill: wallpaper
      source: wallpaper
      autoPaddingEnabled: false
      blurEnabled: root.loadBackground && wallpaper.status === Image.Ready
      blur: 1.0
      blurMax: 128
      blurMultiplier: 1.25
      contrast: -0.08
    }

    MouseArea {
      anchors.fill: parent
      hoverEnabled: true
      onClicked: { root.wakeRequested(); root.forcePasswordFocus() }
      onPositionChanged: root.wakeRequested()
    }

    // Battery icon, pinned top-right as in the old config.
    Text {
      anchors.right: parent.right
      anchors.top: parent.top
      anchors.rightMargin: root.scaled(16)
      anchors.topMargin: root.scaled(16)
      text: root.batteryText
      visible: root.batteryText.length > 0
      color: root.labelColor
      font.family: root.labelFont
      font.pixelSize: root.scaled(19)
    }

    // Date, 355px above centre.
    Text {
      anchors.horizontalCenter: parent.horizontalCenter
      anchors.verticalCenter: parent.verticalCenter
      anchors.verticalCenterOffset: root.scaled(-355)
      text: root.dateText
      color: root.labelColor
      font.family: root.labelFont
      font.pixelSize: root.scaled(24)
    }

    // Clock, 250px above centre.
    Text {
      anchors.horizontalCenter: parent.horizontalCenter
      anchors.verticalCenter: parent.verticalCenter
      anchors.verticalCenterOffset: root.scaled(-250)
      text: root.clockText
      color: root.labelColor
      font.family: root.labelFont
      font.pixelSize: root.scaled(120)
    }

    BorderSurface {
      id: inputField
      width: root.fieldWidth
      height: root.fieldHeight
      anchors.centerIn: parent
      color: root.innerColor
      borderSpec: root.inputBorderSpec
      radius: 8
      clip: true

      TextInput {
        id: passwordInput
        anchors.fill: parent
        anchors.topMargin: inputField.borderTop
        // Reserve the fingerprint icon's width on both sides so the centered
        // dots stay symmetric and never slide under the icon as they grow.
        anchors.rightMargin: inputField.borderRight + 18 + root.fingerprintReserve
        anchors.bottomMargin: inputField.borderBottom
        anchors.leftMargin: inputField.borderLeft + 18 + root.fingerprintReserve
        verticalAlignment: TextInput.AlignVCenter
        horizontalAlignment: TextInput.AlignHCenter
        activeFocusOnPress: true
        clip: true
        enabled: root.inputEnabled && !root.authenticatingPassword
        readOnly: root.authenticatingPassword
        echoMode: TextInput.Password
        passwordCharacter: "●"
        passwordMaskDelay: 0
        color: Color.lock.text
        selectionColor: Color.lock.selection
        selectedTextColor: Color.lock.text
        font.family: Style.font.family
        font.pixelSize: text.length > 0 ? Math.max(1, Math.floor(root.passwordDotFontSize * root.passwordDotScale)) : root.fieldFontSize
        font.letterSpacing: text.length > 0 ? root.passwordDotLetterSpacing * root.passwordDotScale : 0
        cursorVisible: activeFocus && root.showPasswordCursor && text.length > 0
        cursorDelegate: Rectangle {
          width: 2
          color: Color.lock.text
          visible: passwordInput.cursorVisible
        }

        onTextChanged: {
          if (!root.syncingPasswordText) root.passwordTextEdited(text)
          if (text.length > 0) {
            root.wakeRequested()
          }
          if (text.length > 0 && root.failureMessage.length > 0) root.clearFailureRequested()
        }

        onAccepted: {
          var submitted = root.passwordText
          root.passwordTextEdited("")
          if (submitted.length > 0) root.submitPassword(submitted)
        }

        Keys.onPressed: function(event) {
          root.wakeRequested()
          if (event.key === Qt.Key_Escape || (event.modifiers & Qt.ControlModifier && event.key === Qt.Key_U)) {
            root.passwordTextEdited("")
            event.accepted = true
          }
        }
      }

      Text {
        anchors.fill: passwordInput
        text: root.authenticatingPassword ? "Checking…" : (root.failureMessage.length > 0 ? root.failureMessage : root.placeholderText)
        visible: passwordInput.text.length === 0
        color: root.authenticatingPassword ? Color.lock.text : (root.failureMessage.length > 0 ? Color.lock.textError : Color.lock.placeholder)
        font.family: Style.font.family
        font.pixelSize: root.fieldFontSize
        font.italic: !root.authenticatingPassword && root.failureMessage.length > 0
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
      }

      // Fingerprint hint pinned inside the field's right edge when a sensor is
      // enrolled, so the user knows they can touch to unlock instead of typing.
      // Matches hyprlock, which draws its fingerprint icon in the same spot.
      Text {
        id: fingerprintIcon
        objectName: "fingerprintIndicator"
        anchors.right: parent.right
        anchors.rightMargin: inputField.borderRight + 18
        anchors.verticalCenter: parent.verticalCenter
        visible: root.fingerprintConfigured
        text: "󰈷"
        color: Color.lock.placeholder
        font.family: Style.font.family
        font.pixelSize: Math.round(root.fieldFontSize * 1.1)
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
      }
    }

    // Round avatar, 325px below centre.
    Item {
      id: avatar
      width: root.scaled(125)
      height: root.scaled(125)
      anchors.horizontalCenter: parent.horizontalCenter
      anchors.verticalCenter: parent.verticalCenter
      anchors.verticalCenterOffset: root.scaled(325)
      visible: avatarImage.status === Image.Ready

      Image {
        id: avatarImage
        anchors.fill: parent
        source: root.avatarUrl
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        sourceSize.width: 250
        sourceSize.height: 250
        visible: false
      }

      Rectangle {
        id: avatarMask
        anchors.fill: parent
        radius: width / 2
        color: "black"
        visible: false
        layer.enabled: true
      }

      MultiEffect {
        anchors.fill: parent
        source: avatarImage
        maskEnabled: true
        maskSource: avatarMask
      }
    }

    // Name and greeting, below the avatar.
    Text {
      anchors.horizontalCenter: parent.horizontalCenter
      anchors.verticalCenter: parent.verticalCenter
      anchors.verticalCenterOffset: root.scaled(430)
      text: root.userLabel
      color: root.labelColor
      font.family: root.labelFont
      font.pixelSize: root.scaled(18)
    }

    Text {
      anchors.horizontalCenter: parent.horizontalCenter
      anchors.verticalCenter: parent.verticalCenter
      anchors.verticalCenterOffset: root.scaled(460)
      text: root.greetingLabel
      color: root.labelColor
      font.family: root.labelFont
      font.pixelSize: root.scaled(14)
    }
  }
}
