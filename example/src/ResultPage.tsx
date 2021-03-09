import React from "react"
import {View, Text, StyleSheet, Dimensions} from "react-native"
import {NavigationProps} from "react-native-awesome-navigation"

const windowWidth = Dimensions.get('window').width

export const ResultPage = (props: NavigationProps) => {
  return (
    <View style={styles.container}>
      <Text style={styles.text}>{JSON.stringify(props.dataList)}</Text>
    </View>
  )
}

ResultPage.navigationItem = {
  hideNavigationBar: true,
}

const styles = StyleSheet.create({
  container: {
    width: windowWidth,
    backgroundColor: '#FFFFFF',
    justifyContent: 'center',
    alignItems: 'center',
  },
  text: {
    color: 'black',
    width: windowWidth - 50,
    marginTop: 50,
    fontSize: 15,
  },
})