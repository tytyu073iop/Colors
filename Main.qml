import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Window {
    width: 640
    height: 480
    visible: true
    title: qsTr("Colors")
    color: "#6A7039"
    Rectangle {
        id: box
        color: "#000000"
        width: parent.width
        height: parent.height / 3
    }
    Window {
        id: color_picker
        title: "Pick Color"
        visible: false
        property int size: 20
        height: size
        width: size * 14
        component CR: Rectangle {
            required property var arr
            width: color_picker.size
            height: color_picker.size
            color: "#" + rightHex(arr[0]) + rightHex(arr[1]) + rightHex(arr[2])
            MouseArea {
            anchors.fill: parent
                onClicked: {
                    console.log("Rectangle clicked!")
                     // Change color on click
                    r.value = arr[0]
                    g.value = arr[1]
                    b.value = arr[2]
                }
            }
        }
        RowLayout {
            CR {
                arr: [255, 0, 0]; /* red */
            }

            CR {
                arr: [0, 255, 0]; /* green */
            }

            CR {
                arr: [0, 0, 255]; /* blue */
            }

            CR {
                arr: [255, 255, 0]; /* yellow */
            }

            CR {
                arr: [255, 165, 0]; /* orange */
            }

            CR {
                arr: [128, 0, 128]; /* purple */
            }

            CR {
                arr: [255, 192, 203]; /* pink */
            }

            CR {
                arr: [165, 42, 42]; /* brown */
            }

            CR {
                arr: [128, 128, 128]; /* gray */
            }

            CR {
                arr: [0, 128, 128]; /* teal */
            }

            CR {
                arr: [0, 0, 128]; /* navy */
            }
        }
    }

    component SWT: ColumnLayout {
        property alias text: label.text
        property alias from: slider.from
        property alias to: slider.to
        property alias step: slider.stepSize
        property alias value: slider.value
        property bool active: slider.pressed || field.activeFocus
        property alias validator: field.validator
        Text {
            id: label
            text: qsTr("")
        }
        RowLayout {
            Slider {
                id: slider
                stepSize: 1
            }
            TextField {
                id: field
                text: slider.value
                onTextChanged: {
                    slider.value = text
                }
            }
        }
    }
    function rightHex(num) {
        num = Math.round(num).toString(16);
        while (num.length < 2) num = "0" + num;
        return num;
    }

    RowLayout {
        anchors.top: box.bottom
        ColumnLayout {
            id: cmyk
            signal changedCYMK(c: real, y: real, m: real, k: real)
            Connections {
                target: rgb
                function onChanged(r: real, g: real, b: real) {
                    if (cyan.active || magenta.active || yellow.active || key.active) { return; }
                    key.value = Math.min(1 - r/255, 1 - g/255, 1 - b/255)
                    console.log("key " + key.value)
                    console.log(r/255)
                    cyan.value = (1 - r/255 - key.value)/(1 - key.value)*100
                    magenta.value = (1 - g/255 - key.value)/(1 - key.value)*100
                    yellow.value = (1 - b/255 - key.value)/(1 - key.value)*100
                    key.value = key.value * 100
                }
            }
            component CMYK: SWT {
                from: 0
                to: 100
                // validator: IntValidator{bottom: 0; top: 100;}
                onValueChanged: {
                    console.log("CYMK: " + cyan.value)
                    if (!this.active) {
                        return;
                    }
                    cmyk.changedCYMK(cyan.value, yellow.value, magenta.value, key.value)
                }
            }
            CMYK {
                id: cyan
                text: "cyan"
            }
            CMYK {
                id: magenta
                text: "magenta"
            }
            CMYK {
                id: yellow
                text: "yellow"
            }
            CMYK {
                id: key
                text: "key"
            }
            Button {
                text: "Select Color"
                onClicked: {
                    color_picker.visible = true
                }
            }
        }
        ColumnLayout {
            id: xyz
            signal waweChanged(x: real, y:real, z:real)
            Connections {
                function f(x) {
                    return x < 0.04045 ? x / 12.92 : Math.pow((x + 0.055) / 1.055, 2.4)
                }
                function rGBn(r, g, b) {
                    let rn = f(r/255)
                    let gn = f(g/255)
                    let bn = f(b/255)
                    return [rn, gn, bn]
                }
                function matrix(rgbarr) {
                    let x = 0.412453 * rgbarr[0] + 0.357580 * rgbarr[1] + 0.180423 * rgbarr[2]
                    let y = 0.212671 * rgbarr[0] + 0.715160 * rgbarr[1] + 0.072169 * rgbarr[2]
                    let z = 0.019334 * rgbarr[0] + 0.119193 * rgbarr[1] + 0.950227 * rgbarr[2]
                    return [x, y, z]
                }
                target: rgb
                function onWaweChanged(r: real, g: real, b: real) {
                    if (x.active || y.active || z.active) { return; }
                    console.log(r)
                    let arr = matrix(rGBn(r, g, b))
                    x.value = arr[0]
                    y.value = arr[1]
                    z.value = arr[2]
                }
            }
            component XYZ: SWT {
                from: 0
                to: 1
                step: 0.001
                onValueChanged: {}
            }
            XYZ {
                id: x
                text: "X"
                onValueChanged: {
                    if (!this.active) { return; }
                    console.log("x inside: " + x.value)
                    console.log("y inside func: " + y.value)
                    xyz.waweChanged(x.value, y.value, z.value)
                }
            }
            XYZ {
                id: y
                text: "Y"
                onValueChanged: {
                    if (!this.active) { return; }
                    console.log("x inside: " + x.value)
                    console.log("y inside func: " + y.value)
                    xyz.waweChanged(x.value, y.value, z.value)
                }
            }
            XYZ {
                id: z
                text: "Z"
                onValueChanged: {
                    if (!this.active) { return; }
                    console.log("x inside: " + x.value)
                    console.log("y inside func: " + y.value)
                    xyz.waweChanged(x.value, y.value, z.value)
                }
            }
        }
        ColumnLayout {
            id: rgb
            Connections {
                target: cmyk
                function onChangedCYMK(c: real, y: real, m: real, k: real) {
                    if (r.active || g.active || b.active) { return; }
                    r.value = 255*(1 - c/100)*(1 - k/100)
                    console.log(255*(1 - c/100)*(1 - k/100))
                    console.log(r.value)
                    g.value = 255*(1 - m/100)*(1 - k/100)
                    b.value = 255*(1 - y/100)*(1 - k/100)
                    box.color = "#" + rightHex(r.value) + rightHex(g.value) + rightHex(b.value)
                }
            }
            Connections {
                function f(x) {
                    return x < 0.0031308 ? 12.92 * x : 1.055 * Math.pow(x, 1/2.4) - 0.055
                }
                function matrix(x, y, z) {
                    let rn = 3.2406 * x + -1.5372 * y + -0.4986 * z
                    let gn = -0.9689 * x + 1.8758 * y + 0.0415 * z
                    let bn = 0.0557 * x + -0.2040 * y + 1.0570 * z
                    return [rn, gn, bn]
                }
                function itog(arr) {
                    let r = f(arr[0]) * 255
                    let g = f(arr[1]) * 255
                    let b = f(arr[2]) * 255
                    return [r, g, b]
                }
                target: xyz
                function onWaweChanged(x: real, y:real, z:real) {
                    console.log("x: " + x)
                    if (r.active || g.active || b.active) { return; }
                    let arr = itog(matrix(x, y, z))
                    console.log("arr: " + arr)
                    r.value = arr[0]
                    g.value = arr[1]
                    b.value = arr[2]
                }
            }
            component RGB: SWT {
                from: 0
                to: 255
                onValueChanged: {
                    rgb.waweChanged(r.value, g.value, b.value)
                    console.log("#" + rightHex(r.value) + rightHex(g.value) + rightHex(b.value))
                    rgb.changed(r.value, g.value, b.value)
                    box.color = "#" + rightHex(r.value) + rightHex(g.value) + rightHex(b.value)
                }
            }

            signal changed(r: real, g: real, b: real)
            signal waweChanged(r: real, g: real, b: real)
            RGB {
                id: r
                text: "Red"
                onValueChanged: {
                    console.log(r.value)
                }
            }
            RGB {
                id: g
                text: "Green"
            }
            RGB {
                id: b
                text: "Blue"
            }
        }
    }
}
