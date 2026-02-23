import 'package:xml/xml.dart';
import '../../core/document_model.dart';

class DocxParser {
  static Document parse(String xmlString) {
    final doc = Document();
    final document = XmlDocument.parse(xmlString);
    final paragraphsXml = document.findAllElements('w:p');

    for (var p in paragraphsXml) {
      final para = Paragraph();
      final spans = p.findAllElements('w:t');
      for (var s in spans) {
        para.spans.add(Span(s.text));
      }
      doc.paragraphs.add(para);
    }

    return doc;
  }
}
