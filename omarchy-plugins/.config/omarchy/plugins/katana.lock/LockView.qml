import QtQuick
import QtMultimedia
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui

Item {
  id: root

  // --- Service.qml contract. Every property and signal below is bound or
  // --- handled by Service.qml; none may be renamed or removed.
  property bool fingerprintConfigured: false
  property bool authenticatingPassword: false
  property string failureMessage: ""
  property bool inputEnabled: true
  property bool loadBackground: true
  property string passwordText: ""
  property bool syncingPasswordText: false

  signal submitPassword(string password)
  signal passwordTextEdited(string password)
  signal clearFailureRequested()
  signal wakeRequested()

  // --- Layout tokens ------------------------------------------------------
  // Offsets are authored against a 1920x1080 surface and scaled to whatever
  // the real lock surface is, so the layout holds its physical proportions on
  // a scaled display instead of drifting off-screen.
  readonly property real designHeight: 1080
  readonly property real uiScale: height > 0 ? height / designHeight : 1
  function scaled(v) { return Math.round(v * root.uiScale) }

  // JapanRamen.otf ships beside this QML and is loaded by displayFontLoader
  // below, so the styling survives on a machine that never installed the font
  // system-wide. NOTE: the font is licensed personal-use-only — bundling it
  // here is fine locally, but publishing this folder redistributes it.
  // FontLoader.name is the real family; the literal only covers the brief
  // window before the load completes, and the system copy if one exists.
  readonly property string displayFont: displayFontLoader.status === FontLoader.Ready
    ? displayFontLoader.name
    : "JAPAN RAMEN"

  readonly property color textColor: "#f2f3f4"
  readonly property color accentColor: "#6fd8e8"
  readonly property color dimColor: "#a6f2f3f4"
  readonly property color errorColor: "#f7768e"

  readonly property string userLabel: "0xHouss"
  readonly property string sessionLabel: "Hyprland (Wayland)"
  readonly property string placeholderText: "Enter Password"

  readonly property bool errorState: failureMessage.length > 0
  readonly property bool showPasswordCursor: inputEnabled && !authenticatingPassword && !errorState

  property string clockText: ""
  property string dateText: ""

  function forcePasswordFocus() { passwordInput.forceActiveFocus() }

  function syncPasswordText() {
    if (passwordInput.text === passwordText) return
    syncingPasswordText = true
    passwordInput.text = passwordText
    syncingPasswordText = false
  }

  function submitCurrentPassword() {
    var submitted = root.passwordText
    root.passwordTextEdited("")
    if (submitted.length > 0) root.submitPassword(submitted)
  }

  // JAPAN RAMEN maps U+2014 and U+00B7 but draws them as blank glyphs, so the
  // em dash and middot are borrowed from the system font. RichText lets a
  // single label mix the two faces; everything outside the span keeps
  // displayFont. Markup, so anything interpolated in must stay plain ASCII.
  function sysGlyph(ch) {
    return '<span style="font-family:\'' + Style.font.family + '\'">' + ch + '</span>'
  }

  // Reference renders a zero-padded clock and an uppercase "DAY · MONTH DD".
  function updateClock() {
    var now = new Date()
    root.clockText = Qt.formatDateTime(now, "HH:mm")
    root.dateText = Qt.formatDateTime(now, "dddd").toUpperCase()
      + " " + root.sysGlyph("·") + " "
      + Qt.formatDateTime(now, "MMMM dd").toUpperCase()
  }

  onPasswordTextChanged: syncPasswordText()
  onInputEnabledChanged: {
    if (inputEnabled) Qt.callLater(forcePasswordFocus)
  }
  Component.onCompleted: {
    syncPasswordText()
    updateClock()
    if (inputEnabled) Qt.callLater(forcePasswordFocus)
  }

  FontLoader {
    id: displayFontLoader
    source: Qt.resolvedUrl("JapanRamen.otf")
    onStatusChanged: if (status === FontLoader.Error) {
      console.warn("katana.lock: could not load JapanRamen.otf; falling back")
    }
  }

  Timer { interval: 1000; repeat: true; running: true; onTriggered: root.updateClock() }

  Process { id: rebootProcess; command: ["omarchy", "system", "reboot"] }
  Process { id: shutdownProcess; command: ["omarchy", "system", "shutdown"] }

  Rectangle {
    anchors.fill: parent
    color: Color.background

    // Looping video background. The file sits beside this QML so the plugin
    // stays self-contained; Qt.resolvedUrl() keeps it correct across a restow.
    VideoOutput {
      id: wallpaper
      anchors.fill: parent
      fillMode: VideoOutput.PreserveAspectCrop
    }

    MediaPlayer {
      id: wallpaperPlayer
      source: Qt.resolvedUrl("katana.mp4")
      videoOutput: wallpaper
      loops: MediaPlayer.Infinite
      Component.onCompleted: if (root.loadBackground) play()
      onErrorOccurred: function(error, errorString) {
        console.warn("katana.lock: video background failed:", errorString)
      }
    }

    Connections {
      target: root
      function onLoadBackgroundChanged() {
        if (root.loadBackground) wallpaperPlayer.play()
        else wallpaperPlayer.pause()
      }
    }

    // Flat scrim instead of the stock blur pass: a 128px MultiEffect blur is
    // free over a still image but re-runs every frame over video.
    Rectangle {
      anchors.fill: parent
      color: "#000000"
      opacity: 0.32
    }

    MouseArea {
      anchors.fill: parent
      hoverEnabled: true
      onClicked: { root.wakeRequested(); root.forcePasswordFocus() }
      onPositionChanged: root.wakeRequested()
    }

    // --- Top left: clock over date -----------------------------------------
    Column {
      anchors.left: parent.left
      anchors.top: parent.top
      anchors.leftMargin: root.scaled(64)
      anchors.topMargin: root.scaled(40)
      spacing: root.scaled(6)

      Text {
        text: root.clockText
        color: root.textColor
        font.family: root.displayFont
        font.pixelSize: root.scaled(100)
        font.weight: Font.Black
        font.letterSpacing: root.scaled(2)
      }

      Text {
        textFormat: Text.RichText
        text: root.sysGlyph("—") + "  " + root.dateText
        color: root.accentColor
        font.family: root.displayFont
        font.pixelSize: root.scaled(15)
        font.weight: Font.Medium
        font.letterSpacing: root.scaled(3)
      }
    }

    // --- Bottom left: session indicator ------------------------------------
    Text {
      anchors.left: parent.left
      anchors.bottom: parent.bottom
      anchors.leftMargin: root.scaled(64)
      anchors.bottomMargin: root.scaled(52)
      text: "^  " + root.sessionLabel.toUpperCase()
      color: root.dimColor
      font.family: root.displayFont
      font.pixelSize: root.scaled(13)
      font.weight: Font.Medium
      font.letterSpacing: root.scaled(2)
    }

    // --- Bottom right: username, password line, power actions --------------
    Column {
      id: authCluster
      anchors.right: parent.right
      anchors.bottom: parent.bottom
      anchors.rightMargin: root.scaled(64)
      anchors.bottomMargin: root.scaled(46)
      width: root.scaled(430)
      spacing: root.scaled(12)

      Text {
        width: parent.width
        horizontalAlignment: Text.AlignRight
        text: root.userLabel.toUpperCase()
        color: root.textColor
        font.family: root.displayFont
        font.pixelSize: root.scaled(15)
        font.weight: Font.Bold
        font.letterSpacing: root.scaled(3)
      }

      Item {
        width: parent.width
        height: root.scaled(42)

        TextInput {
          id: passwordInput
          anchors.left: parent.left
          anchors.right: fingerprintIcon.visible ? fingerprintIcon.left : submitArrow.left
          anchors.rightMargin: root.scaled(12)
          anchors.bottom: parent.bottom
          anchors.bottomMargin: root.scaled(10)
          // Left-aligned, so TextInput scrolls natively to keep the caret in
          // view. That replaces the stock centred field's shrink-to-fit hack.
          horizontalAlignment: TextInput.AlignLeft
          activeFocusOnPress: true
          clip: true
          enabled: root.inputEnabled && !root.authenticatingPassword
          readOnly: root.authenticatingPassword
          echoMode: TextInput.Password
          passwordCharacter: "●"
          passwordMaskDelay: 0
          color: root.textColor
          selectionColor: root.accentColor
          selectedTextColor: "#000000"
          font.family: root.displayFont
          font.pixelSize: root.scaled(16)
          font.letterSpacing: root.scaled(4)
          cursorVisible: activeFocus && root.showPasswordCursor && text.length > 0
          cursorDelegate: Rectangle {
            width: root.scaled(2)
            color: root.accentColor
            visible: passwordInput.cursorVisible
          }

          onTextChanged: {
            if (!root.syncingPasswordText) root.passwordTextEdited(text)
            if (text.length > 0) root.wakeRequested()
            if (text.length > 0 && root.failureMessage.length > 0) root.clearFailureRequested()
          }

          onAccepted: root.submitCurrentPassword()

          Keys.onPressed: function(event) {
            root.wakeRequested()
            if (event.key === Qt.Key_Escape || (event.modifiers & Qt.ControlModifier && event.key === Qt.Key_U)) {
              root.passwordTextEdited("")
              event.accepted = true
            }
          }
        }

        Text {
          anchors.left: passwordInput.left
          anchors.verticalCenter: passwordInput.verticalCenter
          visible: passwordInput.text.length === 0
          text: root.authenticatingPassword
            ? "CHECKING…"
            : (root.errorState ? root.failureMessage.toUpperCase() : root.placeholderText.toUpperCase())
          color: root.errorState ? root.errorColor : root.dimColor
          font.family: root.displayFont
          font.pixelSize: root.scaled(15)
          font.weight: Font.Medium
          font.letterSpacing: root.scaled(3)
          elide: Text.ElideRight
        }

        // Fingerprint hint, shown only when a sensor is enrolled.
        Text {
          id: fingerprintIcon
          objectName: "fingerprintIndicator"
          anchors.right: submitArrow.left
          anchors.rightMargin: root.scaled(14)
          anchors.top: passwordInput.top
          anchors.bottom: passwordInput.bottom
          verticalAlignment: Text.AlignVCenter
          visible: root.fingerprintConfigured
          text: "󰈷"
          color: root.dimColor
          font.family: Style.font.family
          font.pixelSize: root.scaled(18)
        }

        Text {
          id: submitArrow
          anchors.right: parent.right
          // Span the input's own line box and centre the glyph within it.
          // Anchoring verticalCenter alone left the arrow low: Orbitron has no
          // U+2192, so it fell back to Liberation Sans, whose line metrics do
          // not match the input's. Naming the Nerd Font keeps that decision
          // out of fontconfig's hands.
          anchors.top: passwordInput.top
          anchors.bottom: passwordInput.bottom
          verticalAlignment: Text.AlignVCenter
          horizontalAlignment: Text.AlignHCenter
          text: "→"
          color: passwordInput.text.length > 0 ? root.accentColor : root.dimColor
          font.family: Style.font.family
          font.pixelSize: root.scaled(18)

          MouseArea {
            anchors.fill: parent
            anchors.margins: -root.scaled(10)
            cursorShape: Qt.PointingHandCursor
            onClicked: { root.wakeRequested(); root.submitCurrentPassword() }
          }
        }

        Rectangle {
          anchors.left: parent.left
          anchors.right: parent.right
          anchors.bottom: parent.bottom
          height: root.scaled(2)
          color: root.errorState ? root.errorColor : root.accentColor
          opacity: passwordInput.activeFocus ? 1.0 : 0.7
        }
      }

      Row {
        anchors.right: parent.right
        spacing: root.scaled(28)

        Text {
          text: "RESTART"
          color: restartArea.containsMouse ? root.accentColor : root.dimColor
          font.family: root.displayFont
          font.pixelSize: root.scaled(13)
          font.weight: Font.Medium
          font.letterSpacing: root.scaled(2)

          MouseArea {
            id: restartArea
            anchors.fill: parent
            anchors.margins: -root.scaled(8)
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: rebootProcess.running = true
          }
        }

        Text {
          text: "SHUT DOWN"
          color: shutdownArea.containsMouse ? root.accentColor : root.dimColor
          font.family: root.displayFont
          font.pixelSize: root.scaled(13)
          font.weight: Font.Medium
          font.letterSpacing: root.scaled(2)

          MouseArea {
            id: shutdownArea
            anchors.fill: parent
            anchors.margins: -root.scaled(8)
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: shutdownProcess.running = true
          }
        }
      }
    }
  }
}
