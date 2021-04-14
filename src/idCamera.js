import React from 'react';
import { requireNativeComponent, Text, StyleSheet, View, UIManager, findNodeHandle } from 'react-native';

const IdCamera = requireNativeComponent('IdCamera');

class VouchedIdCamera extends React.PureComponent {

    constructor(props) {
        super(props); 
        this.cameraRef = React.createRef();
    }

    stop = () => {
      UIManager.dispatchViewManagerCommand(
        findNodeHandle(this.cameraRef.current),
        UIManager.IdCamera.Commands.stop,
        []
      );
    };

    restart = () => {
      UIManager.dispatchViewManagerCommand(
        findNodeHandle(this.cameraRef.current),
        UIManager.IdCamera.Commands.restart,
        []
      );
    };

    _onIdStream = (event) => {
      if (!this.props.onIdStream) {
        return;
      }
      this.props.onIdStream(event.nativeEvent)
    }

    render() {
      return (
        <View style={{
            flex: 1,
            flexDirection: 'column',
          }}>
            <IdCamera
              ref={this.cameraRef}
              style={StyleSheet.absoluteFill}
              onIdStream={this._onIdStream}
              enableDistanceCheck={this.props.enableDistanceCheck}
            />
        </View>
      );
    }
}

VouchedIdCamera.defaultProps = {
  enableDistanceCheck: false
}

export { VouchedIdCamera };