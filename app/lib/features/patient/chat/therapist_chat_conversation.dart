import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'chat_menu_drawer.dart';

class TherapistChatConversation extends StatefulWidget {
  final String therapistName;
  final String specialty;
  final String initials;
  final Color color;
  final String image;

  const TherapistChatConversation({
    super.key,
    required this.therapistName,
    required this.specialty,
    required this.initials,
    required this.color,
    required this.image,
  });

  @override
  State<TherapistChatConversation> createState() =>
      _TherapistChatConversationState();
}

class _TherapistChatConversationState
    extends State<TherapistChatConversation> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _ctrl        = TextEditingController();
  final _scrollCtrl  = ScrollController();
  final _db          = FirebaseFirestore.instance;

  // Fallback in-memory list (used only when not logged in)
  final List<_ChatMsg> _localMessages = [];

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  String get _therapistKey =>
      widget.therapistName.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_');

  String get _chatId => _uid != null ? '${_uid}_$_therapistKey' : '';

  CollectionReference<Map<String, dynamic>> get _msgCol =>
      _db.collection('chats').doc(_chatId).collection('messages');

  Future<void> _send() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    _ctrl.clear();

    if (_uid != null) {
      // Persist to Firestore
      final batch = _db.batch();
      final msgRef = _msgCol.doc();
      batch.set(msgRef, {
        'senderId':  _uid,
        'text':      text,
        'isPatient': true,
        'timestamp': FieldValue.serverTimestamp(),
        'isRead':    false,
      });
      batch.set(_db.collection('chats').doc(_chatId), {
        'participantIds': [_uid, _therapistKey],
        'lastMessage':    text,
        'lastMessageAt':  FieldValue.serverTimestamp(),
        'therapistName':  widget.therapistName,
      }, SetOptions(merge: true));
      await batch.commit();
    } else {
      // Not logged in — keep local only
      setState(() => _localMessages.add(_ChatMsg(text, isPatient: true)));
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 80), () {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = MediaQuery.of(context).size.width / 430;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFD2D5DE),
      drawer:
          const ChatMenuDrawer(isAiChatActive: false, isInsideConversation: true),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(s),
            Container(height: 1, color: const Color(0xFFD2D5DE)),
            Expanded(child: _buildMessageArea(s)),
            _buildInput(s),
          ],
        ),
      ),
    );
  }

  // ── Message area (Firestore stream or local list) ────────────────────────

  Widget _buildMessageArea(double s) {
    if (_uid == null) {
      // Not logged in — use local in-memory list
      return _localMessages.isEmpty
          ? _buildEmpty(s)
          : ListView.builder(
              controller: _scrollCtrl,
              padding: EdgeInsets.fromLTRB(16 * s, 20 * s, 16 * s, 8 * s),
              itemCount: _localMessages.length,
              itemBuilder: (_, i) => _buildBubble(_localMessages[i], s),
            );
    }

    // Logged in — stream from Firestore
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _msgCol.orderBy('timestamp').snapshots(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return _buildEmpty(s);
        }
        final docs = snap.data?.docs ?? [];
        if (docs.isEmpty) return _buildEmpty(s);

        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

        return ListView.builder(
          controller: _scrollCtrl,
          padding: EdgeInsets.fromLTRB(16 * s, 20 * s, 16 * s, 8 * s),
          itemCount: docs.length,
          itemBuilder: (_, i) {
            final d = docs[i].data();
            final isPatient = (d['senderId'] as String?) == _uid;
            return _buildBubble(
                _ChatMsg(d['text'] as String? ?? '', isPatient: isPatient), s);
          },
        );
      },
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader(double s) {
    return Container(
      color: const Color(0xFFD2D5DE),
      padding: EdgeInsets.fromLTRB(16 * s, 12 * s, 16 * s, 14 * s),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Icon(Icons.arrow_back_ios_new_rounded,
                size: 20 * s, color: const Color(0xFF292929)),
          ),
          SizedBox(width: 10 * s),
          Container(
            width: 40 * s,
            height: 40 * s,
            decoration: BoxDecoration(
                color: widget.color.withValues(alpha: 0.25),
                shape: BoxShape.circle),
            child: ClipOval(
              child: Image.asset(
                widget.image,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Center(
                  child: Text(widget.initials,
                      style: GoogleFonts.poppins(
                          color: widget.color,
                          fontWeight: FontWeight.w700,
                          fontSize: 13 * s)),
                ),
              ),
            ),
          ),
          SizedBox(width: 10 * s),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(widget.therapistName,
                    style: GoogleFonts.poppins(
                        fontSize: 16 * s,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF1A2E12),
                        letterSpacing: -0.6 * s),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                Text(widget.specialty,
                    style: GoogleFonts.poppins(
                        fontSize: 11 * s,
                        color: const Color(0xFF595959),
                        letterSpacing: -0.4 * s),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _scaffoldKey.currentState?.openDrawer(),
            child: Icon(Icons.menu_rounded,
                size: 26 * s, color: const Color(0xFF595959)),
          ),
        ],
      ),
    );
  }

  // ── Empty state ───────────────────────────────────────────────────────────

  Widget _buildEmpty(double s) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 40 * s),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72 * s,
              height: 72 * s,
              decoration: BoxDecoration(
                  color: widget.color.withValues(alpha: 0.12),
                  shape: BoxShape.circle),
              child: ClipOval(
                child: Image.asset(widget.image,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Center(
                          child: Text(widget.initials,
                              style: GoogleFonts.poppins(
                                  color: widget.color,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 22 * s)),
                        )),
              ),
            ),
            SizedBox(height: 16 * s),
            Text(widget.therapistName,
                style: GoogleFonts.poppins(
                    fontSize: 18 * s,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A2E12),
                    letterSpacing: -0.8 * s)),
            SizedBox(height: 4 * s),
            Text(widget.specialty,
                style: GoogleFonts.poppins(
                    fontSize: 13 * s,
                    color: const Color(0xFF595959),
                    letterSpacing: -0.4 * s)),
            SizedBox(height: 20 * s),
            Text(
              'This is the beginning of your conversation.\nSay hello!',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                  fontSize: 13 * s,
                  color: const Color(0xFF595959).withValues(alpha: 0.7),
                  height: 1.5,
                  letterSpacing: -0.3 * s),
            ),
          ],
        ),
      ),
    );
  }

  // ── Message bubble ────────────────────────────────────────────────────────

  Widget _buildBubble(_ChatMsg msg, double s) {
    final isPatient = msg.isPatient;
    return Padding(
      padding: EdgeInsets.only(bottom: 14 * s),
      child: Row(
        mainAxisAlignment:
            isPatient ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isPatient) ...[
            Container(
              width: 26 * s,
              height: 26 * s,
              decoration: BoxDecoration(
                  color: widget.color.withValues(alpha: 0.25),
                  shape: BoxShape.circle),
              child: ClipOval(
                child: Image.asset(widget.image,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Center(
                          child: Text(widget.initials.substring(0, 1),
                              style: GoogleFonts.poppins(
                                  color: widget.color,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 9 * s)),
                        )),
              ),
            ),
            SizedBox(width: 8 * s),
          ],
          Flexible(
            child: Container(
              padding:
                  EdgeInsets.symmetric(horizontal: 20 * s, vertical: 15 * s),
              constraints: BoxConstraints(maxWidth: 300 * s),
              decoration: BoxDecoration(
                color: isPatient
                    ? const Color(0xFF7F89E9)
                    : const Color(0xFFF0F0F0),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15 * s),
                  topRight: Radius.circular(15 * s),
                  bottomLeft: Radius.circular(isPatient ? 15 * s : 4 * s),
                  bottomRight: Radius.circular(isPatient ? 4 * s : 15 * s),
                ),
                boxShadow: [
                  BoxShadow(
                      color: const Color(0xFF1A2E12).withValues(alpha: 0.10),
                      blurRadius: 4 * s,
                      offset: Offset(0, 4 * s)),
                  BoxShadow(
                      color: const Color(0xFF7F89E9).withValues(alpha: 0.43),
                      blurRadius: 11.6 * s,
                      offset: Offset(0, 4 * s)),
                ],
              ),
              child: Text(msg.text,
                  style: GoogleFonts.poppins(
                      fontSize: 15 * s,
                      color: isPatient
                          ? const Color(0xFFF0F0F0)
                          : const Color(0xFF333333),
                      height: 1.45,
                      letterSpacing: -0.5 * s)),
            ),
          ),
          if (isPatient) ...[
            SizedBox(width: 8 * s),
            Container(
              width: 26 * s,
              height: 26 * s,
              decoration: BoxDecoration(
                  color: const Color(0xFF7F89E9).withValues(alpha: 0.2),
                  shape: BoxShape.circle),
              child: Icon(Icons.person_rounded,
                  color: const Color(0xFF7F89E9), size: 16 * s),
            ),
          ],
        ],
      ),
    );
  }

  // ── Input bar ─────────────────────────────────────────────────────────────

  Widget _buildInput(double s) {
    return Container(
      color: const Color(0xFFD2D5DE),
      padding: EdgeInsets.fromLTRB(35 * s, 8 * s, 16 * s, 20 * s),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 59 * s,
              decoration: BoxDecoration(
                color: const Color(0xFFF0F0F0),
                borderRadius: BorderRadius.circular(100 * s),
                boxShadow: [
                  BoxShadow(
                      color: const Color(0xFF7F89E9).withValues(alpha: 0.23),
                      blurRadius: 7.7 * s,
                      offset: Offset(2 * s, 0)),
                  BoxShadow(
                      color: const Color(0xFFA87CC7).withValues(alpha: 0.22),
                      blurRadius: 13 * s,
                      offset: Offset(-4 * s, 0)),
                ],
              ),
              child: TextField(
                controller: _ctrl,
                cursorColor: const Color(0xFF7F89E9),
                style: GoogleFonts.poppins(
                    fontSize: 15 * s,
                    color: const Color(0xFF515151),
                    letterSpacing: -0.48 * s),
                decoration: InputDecoration(
                  hintText: 'Type your message here',
                  hintStyle: GoogleFonts.poppins(
                      fontSize: 15 * s,
                      color: const Color(0xFF515151).withValues(alpha: 0.6),
                      letterSpacing: -0.48 * s),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                      horizontal: 29 * s, vertical: 18 * s),
                ),
                onSubmitted: (_) => _send(),
              ),
            ),
          ),
          SizedBox(width: 10 * s),
          GestureDetector(
            onTap: _send,
            child: Container(
              width: 51 * s,
              height: 53 * s,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [Color(0xFF7F89E9), Color(0xFFA87CC7)]),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                      color: const Color(0xFF7F89E9).withValues(alpha: 0.43),
                      blurRadius: 11.6 * s,
                      offset: Offset(0, 4 * s)),
                ],
              ),
              child:
                  Icon(Icons.send_rounded, color: Colors.white, size: 22 * s),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatMsg {
  final String text;
  final bool isPatient;
  _ChatMsg(this.text, {required this.isPatient});
}
