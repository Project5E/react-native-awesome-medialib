import React from 'react'
import {StyleSheet, View, Text, ViewStyle} from 'react-native'
import withIPX from './NavigationBar'

interface NavigationBarProps {
  title?: string
  style?: ViewStyle
  opacity?: number
  leftItem?(): Element
  middleItem?(): Element
  rightItem?(): Element
}

const ThreeStageNavigationBar = (props: NavigationBarProps) => {
  const middleView = () => {
    return props.title && props.title.length > 0 ? (
      <Text style={{fontSize: 18}}>{props.title}</Text>
    ) : (
      props.middleItem && props.middleItem()
    )
  }
  return (
    <View style={[styles.navigation, props.style]}>
      <View style={styles.itemContainer}>{props.leftItem && props.leftItem()}</View>
      {middleView()}
      <View style={styles.itemContainer}>{props.rightItem && props.rightItem()}</View>
    </View>
  )
}

export default withIPX(ThreeStageNavigationBar)

const styles = StyleSheet.create({
  navigation: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
  },
  itemContainer: {
    height: '100%',
    width: 80,
    justifyContent: 'center',
  },
})
