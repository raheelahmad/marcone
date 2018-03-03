import Foundation
//import SWXMLHash


let dateStrs = [
 "Fri, 02 Mar 2018 00:00:00 GMT",
 "Fri, 02 Feb 2018 07:00:00 -0600",
 "Fri, 02 Feb 2018 07:00:00 +0000",
 "Fri, 23 Feb 2018 23:59:01 +0000",
 "Thu, 01 Mar 2018 21:00:00 PST",
 "Thu, 01 Mar 2018 10:41:25 -0800",
 "Thu, 01 Mar 2018 21:00:00 PST",
 "Tue, 27 Feb 2018 08:05:00 -0000",
 "Thu, 01 Mar 2018 11:00:00 -0000",
 "Thu, 18 Jan 2018 05:00:00 -0000",
]


/*

func elements(_ name: String, `in` xml: [XMLIndexer]) -> [XMLIndexer] {
    return xml.filter { $0.element?.name == name }
}

func value(_ name: String, `in` xml: [XMLIndexer]) -> String? {
    return xml.filter { $0.element?.name == name }.first?.element?.text
}

func values(_ name: String, `in` xml: [XMLIndexer]) -> [String] {
    return xml.filter { $0.element?.name == name }.flatMap { $0.element?.text }
}

func attr(_ name: String, attr: String, `in` xml: [XMLIndexer]) -> String? {
    return xml.filter { $0.element?.name == name }.first?.value(ofAttribute: attr)
}

func attrs(_ name: String, attr: String, `in` xml: [XMLIndexer]) -> [String] {
    return xml.filter { $0.element?.name == name }.flatMap { $0.value(ofAttribute: attr) }
}


struct Episode {
    let title: String
    let summary: String?
    let episodeDescription: String?
    let publicationDate: String?
    let guid: String?
    let imageURL: String?
    let duration: String?
    let enclosureType: String?
    let enclosureLength: String?
    let enclosureURL: String?
}

extension Episode {
    init?(xml: XMLIndexer) {
        let xmlChildren = xml.children
        let _title: String? = value("title", in: xmlChildren)
        guard let title = _title else { return nil }
        self.title = title
        self.episodeDescription = value("description", in: xmlChildren)
        self.summary = value("itunes:summary", in: xmlChildren)
        self.publicationDate = value("pubDate", in: xmlChildren)
        self.guid = value("guid", in: xmlChildren)


        let image = attr("itunes:image", attr: "href", in: xmlChildren)
        let thumbnail = attr("media:thumbnail", attr: "url", in: xmlChildren)
        self.imageURL = image ?? thumbnail

        self.duration = value("itunes:duration", in: xmlChildren)
        self.enclosureType = attr("enclosure", attr: "type", in: xmlChildren)
        self.enclosureLength = attr("enclosure", attr: "length", in: xmlChildren)
        self.enclosureURL = attr("enclosure", attr: "url", in: xmlChildren)
    }
}

struct Podcast {
    let url: String
    let title: String
    let subtitle: String?
    let podcastDescription: String?
    let summary: String?
    let authorName: String?
    let copyright: String?
    let imageURLStr: String?
    let categories: [String]?

    let episodes: [Episode]
}

extension Podcast: CustomStringConvertible {
    var description: String { return title + " \(episodes.count) episodes" }
}

extension Podcast {
    init?(xml: XMLIndexer) {
        let xmlChildren = xml.children
        let _title: String? = value("title", in: xmlChildren)
        let _urlAtom: String? = attr("atom:link", attr: "href", in: xmlChildren)
        let _urlAtom10: String? = attr("atom10:link", attr: "href", in: xmlChildren)
        let _urlNewFeed: String? = value("itunes:new-feed-url", in: xmlChildren)
        guard let title = _title else { return nil }
        guard let url = (_urlAtom ?? _urlAtom10 ?? _urlNewFeed)  else { return nil }
        self.title = title
        self.url = url
        self.podcastDescription = value("description", in: xmlChildren)
        self.summary = value("itunes:summary", in: xmlChildren)
        self.imageURLStr = attr("itunes:image", attr: "href", in: xmlChildren)
        self.authorName = value("itunes:author", in: xmlChildren)
        self.subtitle = value("itunes:subtitle", in: xmlChildren)
        self.copyright = value("copyright", in: xmlChildren)
        self.categories = attrs("itunes:category", attr: "text", in: xmlChildren)

        self.episodes = elements("item", in: xmlChildren).flatMap(Episode.init)
    }
}

func parseFeed(_ name: String) -> Podcast? {
    do {
        let filePath = Bundle.main.path(forResource:name, ofType: "xml")
        let contentData = FileManager.default.contents(atPath: filePath!)
        let content = String(data:contentData!, encoding:String.Encoding.utf8)!

        let xml = SWXMLHash.parse(content)
        let podcastXML = xml.children.first!.children.first!

        let podcast = Podcast(xml: podcastXML)
        podcast?.episodes.first?.publicationDate
        return podcast
    } catch let error {
        print(error)
        return nil
    }
}

//parseFeed("exponent")

 */
