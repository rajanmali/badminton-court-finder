import { initSentry } from './src/instrument';
import { RootNavigator } from './src/navigation/RootNavigator';

initSentry();

export default function App() {
  return <RootNavigator />;
}
