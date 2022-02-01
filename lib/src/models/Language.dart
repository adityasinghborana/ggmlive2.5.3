
class Languages {
  final int? id;
  final String? name;
  final String? code;

  Languages(
      {this.id,
       this.name,
       this.code});

  static List<Languages> languageList() {
    return <Languages>[
      Languages(id: 1, name: "English", code: "en"),
      Languages(id: 2, name: "اَلْعَرَبِيَّةُ‎", code: "ar"),
      Languages(id: 3, name: "বাংলা", code: "bn"),
    ];
  }
  static List<Languages> languageListEn() {
    return <Languages>[
      Languages(id: 1, name: "English", code: "en"),
    ];
  }static List<Languages> languageListAr() {
    return <Languages>[
    Languages(id: 2, name: "اَلْعَرَبِيَّةُ‎", code: "ar"),
    ];
  }static List<Languages> languageListBn() {
    return <Languages>[
      Languages(id: 3, name: "বাংলা", code: "bn"),
    ];
  }
}
