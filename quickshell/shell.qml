import Quickshell
import QtQuick

ShellRoot {
    PanelWindow {
	anchors.top: true 
	anchors.right: true 
	anchors.left: true 
	visible: true 
	width: 300 
	height: 50 
	color: "#808B0000"
		
	Row{
	anchors.centerIn: parent
	spacing: 10
		
	    Rectangle {
	    id: buttonLeft  	    
	    width: 60
   	    height: 30
   	    color:  "black"
	    }

	    Rectangle {
	        id: buttonMid
            	width:  60 
           	height: 30 
            	color:  interactionArea.pressed ? "red" : (interactionArea.containsMouse ? "gray" : "black")
	    	
		Text {
		    text: "Hi"
		    color: "white"
		    font.pixelSize: 20
		    anchors.centerIn: parent 
	        }
		MouseArea {
		    id: interactionArea
		    anchors.fill: parent
		    hoverEnabled: true
		    onClicked: {
		    console.log("Button wurde geklickt")
		    
		    }
		}
            }

		
	    Rectangle {
	    id: buttonRight
            width:  60 
            height: 30 
            color:  "black"
            }
   	}
   }
}

