//
//  Defaults.swift
//  EhPanda
//
//  Created by 荒木辰造 on R 2/11/22.
//

class Defaults {
    class URL {
        static var host: String {
            if exx {
                if galleryType == .eh {
                    return "https://e-hentai.org/"
                } else {
                    return "https://exhentai.org/"
                }
            } else {
                return "https://e-hentai.org/?inline_set=dm_l&f_cats=767&f_search=parody:durarara$"
            }
        }
        static let cookiesVerify = "https://e-hentai.org/"
        static let login = "https://forums.e-hentai.org/index.php?act=Login"
        
        static let api = "api.php"
        static let favorites = "favorites.php"
        static let search = "f_search="
        static let showComments = "hc=1"
        static let listCompact = "inline_set=dm_l"
        static let detailLarge = "inline_set=ts_l"
        static let ignoreOffensive = "nw=always"
        
        
        static func popularList() -> String {
            host + "?" + listCompact
        }
        static func favoritesList() -> String {
            host + favorites + "?" + listCompact
        }
        static func mangaDetail(url: String) -> String {
            url + "?" + ignoreOffensive + "&" + showComments + "&" + detailLarge
        }
        static func search(keyword: String) -> String {
            host + "?" + listCompact + "&" + search + keyword
        }
        static func addFavorite(id: String, token: String) -> String {
            host + "gallerypopups.php?gid=\(id)&t=\(token)&act=addfav"
        }
        static func contentPage(url: String, page: Int) -> String {
            url + "?p=\(page)"
        }
    }
}
