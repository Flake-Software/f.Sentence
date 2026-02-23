import '../features/docx_reader/docx_extractor.dart';
import '../features/docx_reader/docx_parser.dart';
import 'document_model.dart';

class DocumentService {
  static Document loadDocx(String path) {
    final xmlString = DocxExtractor.extractDocumentXml(path);
    final document = DocxParser.parse(xmlString);
    return document;
  }
}
