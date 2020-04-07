//
//  Profile.swift
//  Trojan
//
//  Created by ParadiseDuo on 2020/3/31.
//  Copyright © 2020 MacClient. All rights reserved.
//

import Foundation

class Profile {
    
    static let shared = Profile()
    
    var client: Client!
    
    var json: [String: AnyObject] {
        get {
            let c: Client = self.client
            let ssl: [String: AnyObject] = ["verify": NSNumber(value: c.ssl.verify) as AnyObject,
                                            "verify_hostname": NSNumber(value: c.ssl.verify_hostname) as AnyObject,
                                            "cert": c.ssl.cert as AnyObject,
                                            "cipher": c.ssl.cipher as AnyObject,
                                            "cipher_tls13": c.ssl.cipher_tls13 as AnyObject,
                                            "sni": c.ssl.sni as AnyObject,
                                            "alpn": c.ssl.alpn as AnyObject,
                                            "reuse_session": NSNumber(value: c.ssl.reuse_session) as AnyObject,
                                            "session_ticket": NSNumber(value: c.ssl.session_ticket) as AnyObject,
                                            "curves": c.ssl.curves as AnyObject
                                           ]
            
            let tcp: [String: AnyObject] = ["no_delay": NSNumber(value: c.tcp.no_delay) as AnyObject,
                                            "keep_alive": NSNumber(value: c.tcp.keep_alive) as AnyObject,
                                            "reuse_port": NSNumber(value: c.tcp.reuse_port) as AnyObject,
                                            "fast_open": NSNumber(value: c.tcp.fast_open) as AnyObject,
                                            "fast_open_qlen": NSNumber(value: c.tcp.fast_open_qlen) as AnyObject
                                           ]
            
            let conf: [String: AnyObject] = ["run_type": c.run_type as AnyObject,
                                             "local_addr": c.local_addr as AnyObject,
                                             "local_port": NSNumber(value: c.local_port) as AnyObject,
                                             "remote_addr": c.remote_addr as AnyObject,
                                             "remote_port": NSNumber(value: c.remote_port) as AnyObject,
                                             "password": c.password as AnyObject,
                                             "log_level": NSNumber(value: c.log_level) as AnyObject,
                                             "ssl": ssl as AnyObject,
                                             "tcp": tcp as AnyObject
                                            ]
            
            return conf
        }
    }
    
    var jsonString: String? {
        get {
            do {
                let data =  try JSONSerialization.data(withJSONObject: self.json, options: JSONSerialization.WritingOptions.prettyPrinted)
                let convertedString = String(data: data, encoding: String.Encoding.utf8)
                return convertedString
            } catch let myJSONError {
                print(myJSONError)
            }
            return ""
        }
    }
    
    func saveProfile() {
        let url = NSURL.fileURL(withPath: CONFIG_PATH)
        do {
            try self.jsonString?.write(to: url, atomically: true, encoding: String.Encoding.utf8)
            
            Trojan.shared.stop()
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+1) {
                Trojan.shared.start()
            }
        } catch let error {
            print("saveProfile: ", error)
        }
    }
    
    func loadProfile() {
        let manager = FileManager.default
        if manager.fileExists(atPath: CONFIG_PATH) {
            do {
                if let data = manager.contents(atPath: CONFIG_PATH) {
                    let f = try JSONDecoder().decode(Client.self, from: data)
                    self.client = f
                } else {
                    self.loadDefaultProfile()
                }
            }catch let error {
                print("loadProfile: ", error)
                self.loadDefaultProfile()
            }
        } else {
            self.loadDefaultProfile()
        }
    }
    
    func loadDefaultProfile() {
        let run_type: String = "client"
        let local_addr: String = "127.0.0.1"
        let local_port: Int = 1080
        let remote_addr: String = "usol97.ovod.me"
        let remote_port: Int = 443
        let password: [String] = ["WxUUph"]
        let log_level: Int = 1
        let verify: Bool = true
        let verify_hostname: Bool = true
        let cert: String = ""
        let cipher: String = "ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-SHA:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES128-SHA:ECDHE-RSA-AES256-SHA:DHE-RSA-AES128-SHA:DHE-RSA-AES256-SHA:AES128-SHA:AES256-SHA:DES-CBC3-SHA"
        let cipher_tls13: String = "TLS_AES_128_GCM_SHA256:TLS_CHACHA20_POLY1305_SHA256:TLS_AES_256_GCM_SHA384"
        let sni: String = ""
        let alpn: [String] = ["h2","http/1.1"]
        let reuse_session: Bool = true
        let session_ticket: Bool = false
        let curves: String = ""
        let no_delay: Bool = true
        let keep_alive: Bool = true
        let reuse_port: Bool = false
        let fast_open: Bool = false
        let fast_open_qlen: Int = 20
        
        let tcp = TCP(no_delay: no_delay, keep_alive: keep_alive, reuse_port: reuse_port, fast_open: fast_open, fast_open_qlen: fast_open_qlen)
        let ssl = SSL(verify: verify, verify_hostname: verify_hostname, cert: cert, cipher: cipher, cipher_tls13: cipher_tls13, sni: sni, alpn: alpn, reuse_session: reuse_session, session_ticket: session_ticket, curves: curves)
        let c = Client(run_type: run_type, local_addr: local_addr, local_port: local_port, password: password, remote_addr: remote_addr, remote_port: remote_port, log_level: log_level, ssl: ssl, tcp: tcp)
        self.client = c
    }
    
    func arguments() -> [String] {
        return ["--log", LOG_PATH, "--config", CONFIG_PATH]
    }
}