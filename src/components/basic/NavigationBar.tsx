import React from 'react'
import {StyleSheet, View} from 'react-native'
import {isIphoneX} from 'react-native-iphone-x-helper'
import {white} from '../../utils/Colors'

const withIPX = <P extends Record<string, any>>(Component: React.ComponentType<P>) => {
  return (props: P) => {
    return (
      <View style={styles(props).container}>
        <Component {...props} />
      </View>
    )
  }
}

export default withIPX

const styles = (props: any) =>
  StyleSheet.create({
    container: {
      backgroundColor: props.style?.backgroundColor ?? white,
      overflow: 'hidden',
      height: isIphoneX() ? 88 : 64,
      justifyContent: 'flex-end',
    },
  })
