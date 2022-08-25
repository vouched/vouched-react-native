import React from 'react';
import { requireNativeComponent, StyleSheet, View, UIManager, findNodeHandle } from 'react-native';

const BarcodeCamera = requireNativeComponent('BarcodeCamera', null);

class VouchedBarcodeCamera extends React.PureComponent {

    constructor(props) {
        super(props);
        this.cameraRef = React.createRef();
    }

    stop = () => {
      UIManager.dispatchViewManagerCommand(
        findNodeHandle(this.cameraRef.current),
        UIManager.BarcodeCamera.Commands.stop,
        []
      );
    };

    restart = () => {
      UIManager.dispatchViewManagerCommand(
        findNodeHandle(this.cameraRef.current),
        UIManager.BarcodeCamera.Commands.restart,
        []
      );
    };
      
    _onBarcodeStream = (event) => {
      if (!this.props.onBarcodeStream) {
        return;
      }
      this.props.onBarcodeStream(event.nativeEvent)
    }

    render() {
        return (
            <View style={{
                flex: 1,
                flexDirection: 'column',
              }}>
                <BarcodeCamera
                    ref={this.cameraRef}
                    style={StyleSheet.absoluteFill}
                    onBarcodeStream={this._onBarcodeStream}
                />
            </View>
        );
    }
}
 
export { VouchedBarcodeCamera };