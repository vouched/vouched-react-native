module.exports = {
  root: true,
  extends: ['prettier', '@react-native-community'],
  plugins: ['prettier'],
  rules: {
    'comma-dangle': ['error', 'never'],
    'prettier/prettier': ['error']
  }
};
