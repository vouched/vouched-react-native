import React from 'react';
import { requireNativeComponent, StyleSheet, View, UIManager, findNodeHandle } from 'react-native';

const FaceCamera = requireNativeComponent('FaceCamera', null);

class VouchedFaceCamera extends React.PureComponent {

    constructor(props) {
        super(props);
        this.cameraRef = React.createRef();
    }

    stop = () => {
      UIManager.dispatchViewManagerCommand(
        findNodeHandle(this.cameraRef.current),
        UIManager.FaceCamera.Commands.stop,
        []
      );
    };

    restart = () => {
      UIManager.dispatchViewManagerCommand(
        findNodeHandle(this.cameraRef.current),
        UIManager.FaceCamera.Commands.restart,
        []
      );
    };
      
    _onFaceStream = (event) => {
      if (!this.props.onFaceStream) {
        return;
      }
      this.props.onFaceStream(event.nativeEvent)
    }

    render() {
        return (
            <View style={{
                flex: 1,
                flexDirection: 'column',
              }}>
                <FaceCamera
                    ref={this.cameraRef}
                    style={StyleSheet.absoluteFill}
                    onFaceStream={this._onFaceStream}
                    livenessMode={this.props.livenessMode}
                />
            </View>
        );
    }
}

VouchedFaceCamera.defaultProps = {
    livenessMode: "NONE"
}
 
export { VouchedFaceCamera };