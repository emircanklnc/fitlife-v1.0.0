import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';
import '../../data/models/chat_message.dart';
import '../../data/models/user_profile.dart' show UserProfile;
import '../../data/repositories/chatbot_repository.dart';
import '../../data/repositories/user_repository.dart';

class ChatbotViewModel extends ChangeNotifier {
  final ChatbotRepository _repository;

  final UserRepository? _userRepository;

  List<ChatMessage> _messages = [];

  bool _isLoading = false;

  String? _errorMessage;

  ChatbotViewModel(this._repository, [this._userRepository]) {
    loadChatHistory();
  }


  List<ChatMessage> get messages => _messages;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;


  Future<void> loadChatHistory() async {
    _isLoading = true;
    notifyListeners();

    try {
      _messages = _repository.getChatHistory();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Sohbet geçmişi yüklenemedi: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> sendMessage(String messageText) async {
    if (messageText.trim().isEmpty) return;

    final userMessage = ChatMessage(
      id: const Uuid().v4(),
      message: messageText,
      isUser: true,
      timestamp: DateTime.now(),
    );

    _messages.add(userMessage);
    await _repository.addMessage(userMessage);
    notifyListeners();

    _isLoading = true;
    notifyListeners();

    try {
      UserProfile? userProfile;
      if (_userRepository != null) {
        try {
          userProfile = await _userRepository!.getUserProfile();
        } catch (e) {
          debugPrint('Profil bilgisi alınamadı: $e');
        }
      }

      final responseText = await _repository.sendMessage(
        messageText,
        userProfile: userProfile,
      );

      final aiMessage = ChatMessage(
        id: const Uuid().v4(),
        message: responseText,
        isUser: false,
        timestamp: DateTime.now(),
      );

      _messages.add(aiMessage);
      await _repository.addMessage(aiMessage);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'AI yanıtı alınamadı: $e';

      final errorMessage = ChatMessage(
        id: const Uuid().v4(),
        message:
            'Üzgünüm, şu anda yanıt veremiyorum. Lütfen daha sonra tekrar deneyin.',
        isUser: false,
        timestamp: DateTime.now(),
      );
      
      _messages.add(errorMessage);
      await _repository.addMessage(errorMessage);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> sendImageMessage(File imageFile) async {
    final userMessage = ChatMessage(
      id: const Uuid().v4(),
      message: '[Fotoğraf gönderildi]',
      isUser: true,
      timestamp: DateTime.now(),
    );

    _messages.add(userMessage);
    await _repository.addMessage(userMessage);
    notifyListeners();

    _isLoading = true;
    notifyListeners();

    try {
      UserProfile? userProfile;
      if (_userRepository != null) {
        try {
          userProfile = await _userRepository!.getUserProfile();
        } catch (e) {
          debugPrint('Profil bilgisi alınamadı: $e');
        }
      }

      final responseText = await _repository.sendImageMessage(
        imageFile,
        userProfile: userProfile,
      );

      final aiMessage = ChatMessage(
        id: const Uuid().v4(),
        message: responseText,
        isUser: false,
        timestamp: DateTime.now(),
      );

      _messages.add(aiMessage);
      await _repository.addMessage(aiMessage);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'AI yanıtı alınamadı: $e';

      final errorMessage = ChatMessage(
        id: const Uuid().v4(),
        message:
            'Üzgünüm, fotoğrafınızı şu anda analiz edemiyorum. Lütfen daha sonra tekrar deneyin.',
        isUser: false,
        timestamp: DateTime.now(),
      );
      
      _messages.add(errorMessage);
      await _repository.addMessage(errorMessage);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> clearHistory() async {
    _messages.clear();
    await _repository.clearHistory();
    notifyListeners();
  }
}
