import React from 'react'
import {TouchableOpacity, Text, Dimensions, StyleSheet, StatusBar, View} from 'react-native'
import {black333, white, black} from '../utils/Colors'
import type {BaseProps} from '../utils/Utils'

// const windowWidth = Dimensions.get('window').width
const windowHeight = Dimensions.get('window').height

export const MediaSelectorPage = (props: BaseProps) => {
  const close = () => {
    props.navigator.dismiss(false)
  }

  return (
    <>
      <StatusBar backgroundColor={black} barStyle="light-content" />
      <View style={[styles.transparentContainer]}>
        <View style={[styles.textContainer]}>
          <TouchableOpacity
            onPress={async () => {
              props.navigator.setResult({type: 'video'})
              props.navigator.dismiss()
            }}>
            <Text style={styles.textStyle}>视频</Text>
          </TouchableOpacity>
          <TouchableOpacity
            onPress={async () => {
              props.navigator.setResult({type: 'image'})
              props.navigator.dismiss()
            }}>
            <Text style={styles.textStyle}>图文</Text>
          </TouchableOpacity>
        </View>
        <View style={styles.cancelButton}>
          <TouchableOpacity onPress={close}>
            <Text style={styles.textStyle}>取消</Text>
          </TouchableOpacity>
        </View>
      </View>
    </>
  )
}

const styles = StyleSheet.create({
  transparentContainer: {
    flex: 1,
    alignItems: 'center',
    backgroundColor: 'black',
  },
  textContainer: {
    width: 135,
    height: 68,
    top: windowHeight - 200,
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  textStyle: {color: white, fontSize: 18, fontWeight: '600'},
  cancelButton: {
    backgroundColor: black333,
    width: 135,
    height: 44,
    justifyContent: 'center',
    alignItems: 'center',
    top: windowHeight - 150,
    borderRadius: 8,
  },
})

MediaSelectorPage.navigationItem = {
  hideNavigationBar: true,
}
