import { StyleSheet, Text, TouchableOpacity, View } from 'react-native';

type ViewMode = 'list' | 'map';

interface Props {
  mode: ViewMode;
  onChange: (mode: ViewMode) => void;
}

export function ViewToggle({ mode, onChange }: Props) {
  return (
    <View style={styles.container}>
      <TouchableOpacity
        style={[styles.btn, mode === 'list' && styles.btnActive]}
        onPress={() => onChange('list')}
        activeOpacity={0.7}
      >
        <Text style={[styles.btnText, mode === 'list' && styles.btnTextActive]}>List</Text>
      </TouchableOpacity>
      <TouchableOpacity
        style={[styles.btn, mode === 'map' && styles.btnActive]}
        onPress={() => onChange('map')}
        activeOpacity={0.7}
      >
        <Text style={[styles.btnText, mode === 'map' && styles.btnTextActive]}>Map</Text>
      </TouchableOpacity>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flexDirection: 'row',
    margin: 12,
    borderRadius: 8,
    backgroundColor: '#f0f0f0',
    padding: 3,
    alignSelf: 'center',
    width: 160,
  },
  btn: {
    flex: 1,
    paddingVertical: 6,
    borderRadius: 6,
    alignItems: 'center',
  },
  btnActive: {
    backgroundColor: '#fff',
    shadowColor: '#000',
    shadowOpacity: 0.08,
    shadowRadius: 4,
    shadowOffset: { width: 0, height: 1 },
    elevation: 2,
  },
  btnText: {
    fontSize: 14,
    fontWeight: '500',
    color: '#888',
  },
  btnTextActive: {
    color: '#111',
    fontWeight: '700',
  },
});
