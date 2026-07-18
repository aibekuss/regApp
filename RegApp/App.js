import React, { useState } from 'react';
import { StyleSheet, Text, View, TextInput, TouchableOpacity, SafeAreaView, KeyboardAvoidingView, Platform, Alert, ActivityIndicator } from 'react-native';

export default function App() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [loading, setLoading] = useState(false); // Жүктелу анимациясы үшін

  // ⚠️ МАҢЫЗДЫ: Осы жерге өзіңнің Google Apps Script веб-сілтемеңді қоясың!
  const GOOGLE_SHEETS_API = 'https://script.google.com/macros/s/AKfycbw-xdwfQgPqyCn0PkmLB7OVSf8lN-PqRwt-k_c3ygJoWr7RkUBEnnAGxeF2P86C5jne2Q/exec'; 

  const handleRegister = async () => {
    // Енгізу өрістерін тексеру
    if (!email || !password) {
      Alert.alert("Қате", "Почта мен парольді толық жазыңыз!");
      return;
    }

    setLoading(true); // Анимацияны қосу

    try {
      // Сенің веб-проектіңдегідей Google Sheets-ке POST сұранысын жіберу
      const response = await fetch(GOOGLE_SHEETS_API, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          email: email,
          password: password,
          registeredAt: new Date().toLocaleString('ru-RU') // Тіркелген уақыты
        }),
      });

      // Егер бәрі сәтті өтсе
      Alert.alert("Керемет!", "Сіз сәтті тіркелдіңіз. Деректер Google Sheets-ке түсті!");
      setEmail('');
      setPassword('');

    } catch (error) {
      // Егер интернеттен немесе сілтемеден қате кетсе
      Alert.alert("Қателік", "Деректерді жіберу мүмкін болмады. Сілтемені тексеріңіз.");
      console.log(error);
    } finally {
      setLoading(false); // Анимацияны өшіру
    }
  };

  return (
    <SafeAreaView style={styles.container}>
      <KeyboardAvoidingView 
        behavior={Platform.OS === 'ios' ? 'padding' : 'height'} 
        style={styles.inner}
      >
        <View style={styles.brandContainer}>
          <Text style={styles.logoText}>REG<Text style={styles.logoAccent}>.APP</Text></Text>
        </View>

        <View style={styles.formContainer}>
          <Text style={styles.title}>Тіркелу</Text>
          <Text style={styles.subtitle}>Жалғастыру үшін деректерді енгізіңіз</Text>
          
          <TextInput 
            style={styles.input} 
            placeholder="Электронды почта (Email)" 
            placeholderTextColor="#666"
            keyboardType="email-address"
            autoCapitalize="none"
            value={email}
            onChangeText={setEmail}
          />

          <TextInput 
            style={styles.input} 
            placeholder="Құпия сөз (Password)" 
            placeholderTextColor="#666"
            secureTextEntry={true}
            autoCapitalize="none"
            value={password}
            onChangeText={setPassword}
          />

          <TouchableOpacity 
            style={styles.button} 
            activeOpacity={0.8}
            onPress={handleRegister}
            disabled={loading}
          >
            {loading ? (
              <ActivityIndicator color="#fff" />
            ) : (
              <Text style={styles.buttonText}>Тіркелу</Text>
            )}
          </TouchableOpacity>
        </View>
      </KeyboardAvoidingView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#0B0F19', // Премиум қою қара-көк түс
  },
  inner: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    paddingHorizontal: 24,
  },
  brandContainer: {
    marginBottom: 40,
  },
  logoText: {
    fontSize: 32,
    fontWeight: '900',
    color: '#FFF',
    letterSpacing: 2,
  },
  logoAccent: {
    color: '#007AFF', // Көк түсті акцент
  },
  formContainer: {
    width: '100%',
    backgroundColor: '#131A2C', // Форманың фоны
    padding: 28,
    borderRadius: 24,
    borderWidth: 1,
    borderColor: '#1E2943',
  },
  title: {
    fontSize: 24,
    fontWeight: 'bold',
    marginBottom: 6,
    color: '#FFF',
  },
  subtitle: {
    fontSize: 14,
    color: '#657593',
    marginBottom: 24,
  },
  input: {
    width: '100%',
    height: 56,
    backgroundColor: '#1C263E',
    borderRadius: 14,
    paddingHorizontal: 18,
    marginBottom: 16,
    fontSize: 16,
    color: '#FFF',
    borderWidth: 1,
    borderColor: '#263557',
  },
  button: {
    width: '100%',
    height: 56,
    backgroundColor: '#007AFF',
    borderRadius: 14,
    alignItems: 'center',
    justifyContent: 'center',
    marginTop: 8,
    shadowColor: '#007AFF',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.3,
    shadowRadius: 8,
    elevation: 4,
  },
  buttonText: {
    color: '#fff',
    fontSize: 16,
    fontWeight: '700',
  },
});