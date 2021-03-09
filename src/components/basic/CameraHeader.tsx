import React from 'react'
import {TouchableOpacity, Image, StyleSheet} from 'react-native'
import ThreeStageNavigationBar from './ThreeStageNavigationBar'
import GoBackArrowIcon from '../../images/go_back_arrow.png'
import {black, white} from '../../utils/Colors'

interface HeaderProps {
  onPress(): void
}

const CameraNavigationBar = (props: HeaderProps) => {
  return (
    <ThreeStageNavigationBar
      leftItem={() => (
        <TouchableOpacity
          onPress={() => {
            props.onPress()
          }}
          style={styles.backIconContainer}>
          <Image source={GoBackArrowIcon} style={styles.backIcon} />
        </TouchableOpacity>
      )}
      style={{backgroundColor: black}}
    />
  )
}
export default CameraNavigationBar
const styles = StyleSheet.create({
  backIconContainer: {
    justifyContent: 'center',
    height: 28,
    width: 28,
    marginLeft: 16,
  },
  backIcon: {width: 28, height: 28, tintColor: white},
})
