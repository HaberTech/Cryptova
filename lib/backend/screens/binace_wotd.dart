import 'package:html/parser.dart';
import 'package:html/dom.dart' as dom;
import 'package:http/http.dart' as http;

bool listEquals(List<String> list1, List<String> list2) {
  if (list1.length != list2.length) {
    return false;
  }
  for (int i = 0; i < list1.length; i++) {
    if (list1[i] != list2[i]) {
      return false;
    }
  }
  return true;
}

Future<String> _fetchHtmlBody() async {
  final Uri url = Uri.parse("https://shoptips24.com/online-earning-tips/7985/");
  final http.Response response = await http.get(url);
  final String body = response.body.toString();
  return body;
}

Future<List<List<String>>> getWords() async {
  List<List<String>> words = []; // [[], []]
  String htmlBody = await _fetchHtmlBody();
  dom.Document document = parse(htmlBody);
  List<dom.Element> ul = document.querySelectorAll('ul');

  for (dom.Element list in ul) {
    String text = list.text.trim();
    if (list.className == '' && list.children[0].text.length <= 16) {
      List<String> listTextItems = text.split('\n');
      words.removeWhere((wordArray) => listEquals(wordArray, listTextItems));
      words.add(listTextItems);
    }
  }

  return words;
}