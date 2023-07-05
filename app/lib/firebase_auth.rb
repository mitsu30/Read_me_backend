# JWTのデコード化とエンコード化
require "jwt"
# HTTPリクエストを送るため
require "net/http"

module FirebaseAuth
  # 認証で使用する署名アルゴリズム（RS256）を指定している。
  ALGORITHM = "RS256".freeze

  # Google Firebaseが発行するJWTのissuerクレームについて設定。
  # 自身のプロジェクトに対して生成されたトークンの発行元はこのURLになる。
  # これらを組み沢せることで実際のissクレームの値を構成する。
  ISSUER_PREFIX = "https://securetoken.google.com/".freeze
  FIREBASE_PROJECT_ID = ENV["FIREBASE_PROJECT_ID"]

  # Google公開鍵証明書リストを読み込むためのURL。
  # 証明書のキーは、token headerから得たキーID。
  CERT_URI =
    "https://www.googleapis.com/robot/v1/metadata/x509/securetoken@system.gserviceaccount.com".freeze

    #  IDトークンを検証するメソッド
    def verify_id_token(id_token)
      # トークンをデコードしてペイロードとヘッダーを取得する
      payload, header = decode_unverified(id_token)
      # 取得したヘッダーを使って公開鍵を取得する
      public_key = get_public_key(header)
      # 公開鍵を使ってIDトークンを検証する
      errors = verify(id_token, public_key)
    

      # token検証に成功したら、ユーザーuidを返し、失敗したら、error情報を返す。
    
      if errors.empty?
        return { uid: payload["user_id"] }
      else
        return { errors: errors.join(" / ") }
      end
    end

    private
    
    # decode_tokenメソッドと合わせてIDトークンを検証せずにデコード化するメソッド。
    # 公開鍵を取得するためにheaderが必要あるため、最初の段階では検証せずにデコードを行う。
    def decode_unverified(token)
      decode_token(
        token: token,
        key: nil,
        verify: false,
        options: {
          algorithm: ALGORITHM,
        },
      )
    end
    
    # Returns:
    #    Array: decoded data of ID token =>
    #     [
    #      {"data"=>"data"}, # payload
    #      {"typ"=>"JWT", "alg"=>"alg", "kid"=>"kid"} # header
    #     ]
    def decode_token(token:, key:, verify:, options:)
      JWT.decode(token, key, verify, options)
    end
    
    # headerから公開鍵を取得するためのメソッド。
    # headerからkidを取得してそれに対応する公開鍵証明書を検索する。
    # 証明書が見つかったら公開鍵を抽出する。
    def get_public_key(header)
      certificate = find_certificate(header["kid"])
      public_key = OpenSSL::X509::Certificate.new(certificate).public_key
    rescue OpenSSL::X509::CertificateError => e
      raise "Invalid certificate. #{e.message}"
  
      return public_key
    end

    # fetch_certificatesメソッドと合わせて公開鍵証明書を取得するメソッド。
    # Googleの公開鍵証明書リストを取得し、その中から指定されたkidに対応する証明書を探す。
    def find_certificate(kid)
      certificates = fetch_certificates 
      unless certificates.keys.include?(kid)
        raise "Invalid 'kid', do not correspond to one of valid public keys."
      end
  
      valid_certificate = certificates[kid]
      return valid_certificate
    end
  
    # CERT_URIから有効なgoogle公開鍵証明書リストを取得する。
    # 証明書を取得したら、JSONレスポンスを解析して、証明書を返します。
    def fetch_certificates
      uri = URI.parse(CERT_URI)
      https = Net::HTTP.new(uri.host, uri.port)
      https.use_ssl = true
  
      req = Net::HTTP::Get.new(uri.path)
      res = https.request(req)
      unless res.code == "200"
        raise "Error: can't obtain valid public key certificates from Google."
      end
  
      certificates = JSON.parse(res.body)
      return certificates
    end
  
    # 与えられたJWTトークンの署名とデータの有効性を検証する
    # トークンに何か問題がある場合は、エラーメッセージを返す。
    # 基本的にはJWT.decodeで自動検証
    def verify(token, key)
      errors = []
  
      begin
        decoded_token =
          decode_token(
            token: token,
            key: key,
            verify: true,
            options: decode_options,
          )
      # JWTの有効期限が切れた場合に発生
      rescue JWT::ExpiredSignature
        return ["Firebase ID token has expired. Get a fresh token from your app and try again."]
      # iat（Issued At）クレームが無効な場合に発生
      rescue JWT::InvalidIatError
        return ["Invalid ID token. 'Issued-at time' (iat) must be in the past."]
      # iss（Issuer）クレームが無効な場合に発生
      rescue JWT::InvalidIssuerError
        return ["Invalid ID token. 'Issuer' (iss) Must be 'https://securetoken.google.com/<firebase_project_id>'."]
      # aud（Audience）(トークンの受取人)クレームが無効な場合に発生
      rescue JWT::InvalidAudError
        return ["Invalid ID token. 'Audience' (aud) must be your Firebase project ID."]
      # トークンの署名が無効な場合、つまりトークンが改ざんされた可能性がある場合に発生
      rescue JWT::VerificationError => e
        return ["Firebase ID token has invalid signature. #{e.message}"]
      # トークンのデコードが何らかの理由で失敗した場合に発生
      rescue JWT::DecodeError => e
        return ["Invalid ID token. #{e.message}"]
      end
  
      # subとalgはJWT.decodeで自動検証できないため、追加検証が必要
      # デコードしたトークンからSubject(件名)とAlgorithmの値を取り出す。
      sub = decoded_token[0]["sub"]
      alg = decoded_token[1]["alg"]
  
      # subはuidとなるユニークな値で、文字列で空でないことを検証
      unless sub.is_a?(String) && !sub.empty?
        errors << "Invalid ID token. 'Subject' (sub) must be a non-empty string."
      end
  
      # algはALGORITHM(RS256)と一致することを検証
      unless alg == ALGORITHM
        errors << "Invalid ID token. 'alg' must be '#{ALGORITHM}', but got #{alg}."
      end
  
      return errors
    end
    
    # JWTの検証に必要なオプションを設定するメソッド。
    def decode_options
      {
        iss: ISSUER_PREFIX + FIREBASE_PROJECT_ID,
        aud: FIREBASE_PROJECT_ID,
        algorithm: ALGORITHM,
        verify_iat: true,
        verify_iss: true,
        verify_aud: true,
      }
    end
  end

    


