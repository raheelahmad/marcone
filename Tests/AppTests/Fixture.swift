//
//  Fixture.swift
//  AppTests
//
//  Created by Raheel Ahmad on 4/23/18.
//

import Foundation

let podcastToParseStr = """
<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" media="screen" href="/~d/styles/rss2enclosuresfull.xsl"?><?xml-stylesheet type="text/css" media="screen" href="http://feeds.gimletmedia.com/~d/styles/itemcontent.css"?><rss xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd" xmlns:atom="http://www.w3.org/2005/Atom" xmlns:media="http://search.yahoo.com/mrss/" version="2.0">
<channel>

<title>Reply All</title>
<link>http://gimletmedia.com/shows/reply-all</link>
<language>en</language>
<copyright>All rights reserved</copyright>
<description>"'A podcast about the internet' that is actually an unfailingly original exploration of modern life and how to survive it." - The Guardian. Hosted by PJ Vogt and Alex Goldman, from Gimlet.</description>
<image>
<url>http://static.megaphone.fm/podcasts/05f71746-a825-11e5-aeb5-a7a572df575e/image/uploads_2F1516902193862-jqkml22bswo-cee641b4533ddb31a5a7ab656fe45116_2FCURRENT_Reply%2BAll%2BLogo.png</url>
<title>Reply All</title>
<link>http://gimletmedia.com/shows/reply-all</link>
</image>
<itunes:explicit>yes</itunes:explicit>
<itunes:type>episodic</itunes:type>
<itunes:subtitle>"'A podcast about the internet' that is actually an unfailingly original exploration of modern life and how to survive it." - The Guardian. Hosted by PJ Vogt and Alex Goldman, from Gimlet.</itunes:subtitle>
<itunes:author>Gimlet</itunes:author>
<itunes:summary>"'A podcast about the internet' that is actually an unfailingly original exploration of modern life and how to survive it." - The Guardian. Hosted by PJ Vogt and Alex Goldman, from Gimlet.</itunes:summary>
<itunes:owner>
<itunes:name>Gimlet</itunes:name>
<itunes:email>feeds@soundcloud.com</itunes:email>
</itunes:owner>
<itunes:image href="http://static.megaphone.fm/podcasts/05f71746-a825-11e5-aeb5-a7a572df575e/image/uploads_2F1516902193862-jqkml22bswo-cee641b4533ddb31a5a7ab656fe45116_2FCURRENT_Reply%2BAll%2BLogo.png" />
<itunes:category text="Technology">
</itunes:category>
<itunes:category text="Society &amp; Culture">
</itunes:category>
<itunes:category text="Arts">
</itunes:category>
<atom10:link xmlns:atom10="http://www.w3.org/2005/Atom" rel="self" type="application/rss+xml" href="http://feeds.gimletmedia.com/hearreplyall" /><feedburner:info xmlns:feedburner="http://rssnamespace.org/feedburner/ext/1.0" uri="hearreplyall" /><atom10:link xmlns:atom10="http://www.w3.org/2005/Atom" rel="hub" href="http://pubsubhubbub.appspot.com/" /><media:copyright>All rights reserved</media:copyright><media:thumbnail url="http://static.megaphone.fm/podcasts/05f71746-a825-11e5-aeb5-a7a572df575e/image/uploads_2F1516902193862-jqkml22bswo-cee641b4533ddb31a5a7ab656fe45116_2FCURRENT_Reply%2BAll%2BLogo.png" /><media:keywords>Storytelling</media:keywords><media:category scheme="http://www.itunes.com/dtds/podcast-1.0.dtd">Technology</media:category><media:category scheme="http://www.itunes.com/dtds/podcast-1.0.dtd">Society &amp; Culture</media:category><media:category scheme="http://www.itunes.com/dtds/podcast-1.0.dtd">Arts</media:category><itunes:keywords>Storytelling</itunes:keywords><item>
<title>#119 No More Safe Harbor</title>
<description>Last month, the government shut down backpage.com, a site where people advertised sex with children. We talk to a group of people who say that was a huge mistake.&lt;br&gt;&lt;br&gt;Trigger warning: sexual assault.&lt;br&gt;&lt;br&gt;</description>
<pubDate>Fri, 20 Apr 2018 05:29:00 -0000</pubDate>
<itunes:author>Gimlet</itunes:author>
<itunes:episodeType>full</itunes:episodeType>
<itunes:subtitle />
<itunes:summary>
<![CDATA[Last month, the government shut down backpage.com, a site where people advertised sex with children. We talk to a group of people who say that was a huge mistake.<br><br>Trigger warning: sexual assault.<br><br>]]>
</itunes:summary>
<itunes:duration>1842</itunes:duration>
<itunes:explicit>yes</itunes:explicit>
<guid isPermaLink="false"><![CDATA[5c44f984-c0e6-11e7-9927-2f294a6d2ae5]]></guid>
<enclosure url="https://traffic.megaphone.fm/GLT2084498231.mp3?updated=1524201373" length="37369939" type="audio/mpeg" />
<dc:creator xmlns:dc="http://purl.org/dc/elements/1.1/">Gimlet</dc:creator><media:content url="https://traffic.megaphone.fm/GLT2084498231.mp3?updated=1524201373" fileSize="37369939" type="audio/mpeg" /><itunes:keywords>Storytelling</itunes:keywords></item>
<item>
<title>#118 A Pirate In Search of a Judge</title>
<description>One day, Cayden received an email from their internet provider that said "stop pirating TV shows or we'll cut off your internet!" Cayden had no idea what they were talking about. So Alex decided to investigate.&lt;br&gt;&lt;br&gt;&lt;strong&gt;Further Reading&lt;/strong&gt; &lt;br&gt;&lt;a href="http://www.vulture.com/2016/03/girls-recap-season-5-episode-4.html"&gt;Vulture's recap of "Old Loves" (Girls Season 5, Episode 4)&lt;/a&gt;</description>
<pubDate>Thu, 15 Mar 2018 10:00:00 -0000</pubDate>
<itunes:author>Gimlet</itunes:author>
<itunes:title>#118 A Pirate In Search of a Judge</itunes:title>
<itunes:episodeType>full</itunes:episodeType>
<itunes:subtitle />
<itunes:summary>
<![CDATA[One day, Cayden received an email from their internet provider that said "stop pirating TV shows or we'll cut off your internet!" Cayden had no idea what they were talking about. So Alex decided to investigate.<br><br><strong>Further Reading</strong> <br><a href="http://www.vulture.com/2016/03/girls-recap-season-5-episode-4.html">Vulture's recap of "Old Loves" (Girls Season 5, Episode 4)</a>]]>
</itunes:summary>
<itunes:duration>2018</itunes:duration>
<itunes:explicit>yes</itunes:explicit>
<guid isPermaLink="false"><![CDATA[5c2d368c-c0e6-11e7-9927-2fea8872efcd]]></guid>
<enclosure url="https://traffic.megaphone.fm/GLT5587369271.mp3?updated=1521093315" length="41601149" type="audio/mpeg" />
<dc:creator xmlns:dc="http://purl.org/dc/elements/1.1/">Gimlet</dc:creator><media:content url="https://traffic.megaphone.fm/GLT5587369271.mp3?updated=1521093315" fileSize="41601149" type="audio/mpeg" /><itunes:keywords>Storytelling</itunes:keywords></item>
<media:credit role="author">Gimlet</media:credit><media:rating>adult</media:rating><media:description type="plain">"'A podcast about the internet' that is actually an unfailingly original exploration of modern life and how to survive it." - The Guardian. Hosted by PJ Vogt and Alex Goldman, from Gimlet.</media:description></channel>
</rss>

"""
