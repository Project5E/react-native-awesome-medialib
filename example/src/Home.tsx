import React, {useEffect} from 'react'
import {View, Text, TouchableOpacity, StyleSheet, Dimensions} from 'react-native'
import {InvokeType, rxEventBus, OnNextStepNotification} from 'react-native-awesome-medialib'
import {NavigationProps} from 'react-native-awesome-navigation'

const windowWidth = Dimensions.get('window').width
const windowHeight = Dimensions.get('window').height

export const Home = (props: NavigationProps) => {

  useEffect(() => {
    const subs = rxEventBus.listen(OnNextStepNotification).subscribe(value => {
      console.warn(`i have received message:${JSON.stringify(value)}`)
      console.warn(`navigator:${JSON.stringify(props)}`)
      props.navigator.push('ResultPage', value)
    })
    return () => {
      subs.unsubscribe()
    }
  }, [props])

  const onPress = async () => {
    const resp = await props.navigator.present(
      'MediaSelectorPage',
      {},
      {isFullScreen: true, isTransparency: true, animated: true, isTabBarPresented: false}
    )
    if (!resp) {
      return
    }
    let params
    if (resp.type === 'video') {
      params = {
        maxSelectedMediaCount: 1,
        isVideoOnly: true,
        from: InvokeType.main,
      }
    } else {
      params = {
        maxSelectedMediaCount: 9,
        isVideoOnly: false,
        from: InvokeType.main,
      }
    }
    props.navigator.present('MediaLibraryPage', params, {
      isFullScreen: true,
      isTabBarPresented: true,
    })
  }

  return (
    <View style={styles.container}>
      <TouchableOpacity onPress={onPress} style={styles.buttonStyle}>
        <Text style={styles.textStyle}>打开图片选择器</Text>
      </TouchableOpacity>
    </View>
  )
}

Home.navigationItem = {
  hideNavigationBar: true,
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#FFFFFF',
    justifyContent: 'space-between',
  },
  buttonStyle: {
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#333333',
    height: 50,
    width: 150,
    left: (windowWidth - 150) / 2,
    top: (windowHeight - 50) / 2,
    marginTop: 8,
    marginBottom: 8,
    paddingLeft: 8,
    paddingRight: 8,
    borderRadius: 8,
  },
  textStyle: {
    color: '#FFFFFF',
  },
})
