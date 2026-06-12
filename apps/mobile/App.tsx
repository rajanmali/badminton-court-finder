import { initSentry } from './src/instrument';
import { RootNavigator } from './src/navigation/RootNavigator';
import { QueryProvider } from './src/providers/QueryProvider';

initSentry();

export default function App() {
  return (
    <QueryProvider>
      <RootNavigator />
    </QueryProvider>
  );
}
