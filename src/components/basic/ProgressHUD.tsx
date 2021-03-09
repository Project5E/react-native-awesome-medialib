import React from 'react'
import {View, StyleSheet, ActivityIndicator} from 'react-native'
import {black333} from '../../utils/Colors'

export interface Props {
  color?: string
}

const ProgressHUD = (props: Props) => {
  return (
    <View style={style.container}>
      <ActivityIndicator color={props.color ?? black333} size="large" />
    </View>
  )
}

const style = StyleSheet.create({
  container: {
    position: 'absolute',
    width: '100%',
    height: '100%',
    justifyContent: 'center',
    alignItems: 'center',
  },
})

export default ProgressHUD
