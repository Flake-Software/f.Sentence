class Document {
  List<Paragraph> paragraphs = [];
}

class Paragraph {
  List<Span> spans = [];
}

class Span {
  String text;
  Span(this.text);
}
