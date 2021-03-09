import React from 'react'
import {StyleSheet, TouchableOpacity, View, Text} from 'react-native'
import {isIphoneX} from 'react-native-iphone-x-helper'
import {black1A, gray73, white} from '../../utils/Colors'

interface Props {
  selectedMediaCount: number
  onDoneButtonPress(): void
}

export const MediaLibraryBottomToolBar = (props: Props) => {
  return (
    <View style={bottomToolBarStyle().container}>
      <View style={bottomToolBarStyle().background}>
        <Text style={bottomToolBarStyle().selectCountText}>已选 {props.selectedMediaCount} 张</Text>
        <TouchableOpacity
          disabled={props.selectedMediaCount === 0}
          onPress={() => props.onDoneButtonPress()}
          style={bottomToolBarStyle().doneButton}>
          <Text style={bottomToolBarStyle(props.selectedMediaCount).doneButtonText}>下一步</Text>
        </TouchableOpacity>
      </View>
    </View>
  )
}

export const bottomToolBarStyle = (selectCount?: number) =>
  StyleSheet.create({
    container: {height: isIphoneX() ? 84 : 50, backgroundColor: black1A},
    background: {
      height: 50,
      backgroundColor: black1A,
      flexDirection: 'row',
      alignItems: 'center',
      justifyContent: 'space-between',
    },
    selectCountText: {
      color: white,
      fontSize: 14,
      left: 16,
      fontWeight: '600',
    },
    doneButton: {
      width: 56,
      height: 25,
      right: 16,
      justifyContent: 'center',
    },
    doneButtonText: {
      fontSize: 18,
      fontWeight: '600',
      color: selectCount && selectCount > 0 ? white : gray73,
    },
  })
