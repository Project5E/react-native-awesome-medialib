import {StyleSheet, Dimensions} from 'react-native'
import {white, black} from '../../utils/Colors'
import merge from 'deepmerge'

export const windowWidth = Dimensions.get('window').width
export const windowHeight = Dimensions.get('window').height

const PROGRESS_MARGIN = 16

export const inlineStyle = StyleSheet.create({
  container: {},
  viewContainer: {
    width: '100%',
    height: '100%',
    position: 'relative',
    backgroundColor: white,
  },
  video: {
    width: '100%',
    height: '100%',
    backgroundColor: black,
  },
  controlContainer: {
    position: 'absolute',
    width: '100%',
    height: '100%',
    top: 0,
    left: 0,
    zIndex: 2,
  },
  controlPlayerWrapper: {
    position: 'absolute',
    width: 50,
    height: 50,
    top: '50%',
    left: '50%',
    transform: [{translateX: -25}, {translateY: -25}],
    overflow: 'hidden',
  },
  controlTitleWrapper: {
    paddingTop: 20,
    paddingLeft: 50,
  },
  controlTitle: {
    fontSize: 22,
    fontWeight: '600',
    color: white,
  },
  controlToolBar: {
    position: 'absolute',
    width: '100%',
    height: 37,
    left: 0,
    bottom: 0,
    paddingLeft: 13,
    paddingRight: 13,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
  },
  toolBarFullscreen: {
    width: 24,
    height: 24,
  },
  toolBarProgress: {
    flex: 1,
    height: 2,
    marginLeft: PROGRESS_MARGIN,
    marginRight: PROGRESS_MARGIN,
    backgroundColor: white,
  },
  toolBarProgressTrack: {
    position: 'relative',
    width: 0,
    height: '100%',
    backgroundColor: white,
  },
  toolBarTrackPoint: {
    position: 'absolute',
    top: '50%',
    right: 0,
    width: 16,
    height: 16,
    transform: [{translateX: 8}, {translateY: -8}],
    backgroundColor: white,
    borderRadius: 16,
  },
  toolBarTimeText: {
    color: white,
    textAlign: 'center',
    fontWeight: '500',
    fontSize: 12,
    width: 47,
  },
  toolBarDuration: {
    marginRight: 20,
  },
})

export const fullscreenStyle = merge(
  inlineStyle,
  StyleSheet.create({
    container: {
      position: 'absolute',
      zIndex: 3,
      top: 0,
      left: 0,
      // 伪全屏宽高互换
      width: windowHeight,
      height: windowWidth,
      backgroundColor: black,
      transform: [
        {translateY: windowHeight * 0.5 - windowWidth * 0.5},
        {translateX: windowWidth * 0.5 - windowHeight * 0.5},
        {rotate: '90deg'},
      ],
    },
    toolBarTimeText: {
      fontSize: 16,
    },
  })
)
