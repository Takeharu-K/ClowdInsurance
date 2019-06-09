#Clowd Insurance

現在の保険会社を通したシステムでは，短期間の保険をかけるには，あまりにも多くの手順が必要です．保険会社に連絡し，プランを選択して，事故発生時の事実確認にあまりにも手間がかかります．そこでこの課題を解決するために，私たちのClowd Insuranceは「短期間の保険を格安で提供」します．これはオンラインで申し込んで格安の手数料ですぐに適用できます．事実確認も独自の投票システムで簡単に完了します．

## Inspiration
短期間の保険を簡単にかけたい．

## What it does
申込者がEthereumネットワークに保険料を支払う．
事故が発生し，保険金をもらいたい申込者は，システムにチャレンジを発行する．
チャレンジした申込者は事実を確認できる写真などをアップロードする．

チャレンジが発行されると不特定多数の投票者が検証に参加できる．
投票者は本当に事故が発生したか否かを判断して，YesかNoを投票する．
この時，デポジットとして少額のETHを支払う．

最終的にチャレンジ期間が終了した時に過半数がYesの投票をした場合に，申込者は保険金を受け取ることができる．
Noの投票が過半数を獲得した場合には，保険金を受け取ることはできない．

投票者は，チャレンジ期間が終了した時に，過半数の投票をした場合にデポジットと少額の報酬を得ることができる．
一方で，少数派の投票をした投票者はデポジットを失う．

このように設計することで，投票者は慎重にチャレンジの真偽を判断するようになる．

投票者が大勢いる場合に，より正しい選択をするようになる．

## How I built it
Ethereumのテストネットに保険コントラクトをデプロイ．
FirebaseにホスティングしたWebページからコントラクトを実行する．
保険の内容をFirestoreに保存する．

## Challenges I ran into

設計では，申込者と投票者のインセンティブ設計が難しかった．

実装では，保険コントラクトの実行条件が複雑になってしまうので，そこの対処が難しかった．
また，フロントエンドとEthereumとのやりとりの接続に手間取った．

## Accomplishments that I'm proud of
保険コントラクトのような金融系のコントラクトをなんとか作成することができた．
また，投票者のインセンティブ設計が程よいバランスになった．

## What I learned
インセンティブ設計がサービスの肝となること．
コントラクトの複雑性が増すと指数関数的にシステムの脆弱性が増してしまうこと．
また，素晴らしいフロントページを作るのには時間がかかること．

## What's next for Clowd Insurance
コントラクトの脆弱性を減らすこと．
投票者への報酬設計を変える．

##web
https://clowd-insurance.firebaseapp.com/

##devpost
https://devpost.com/software/clowd-insurance

##スライド
https://docs.google.com/presentation/d/1DWlA2xXq_RKslU-oQ0a80b33-sDYzOq0/edit#slide=id.p1

##github
コントラクト
https://github.com/Takeharu-K/ClowdInsurance

フロント
https://github.com/shoooooman/clowd-insurance-front


##etherscan
https://rinkeby.etherscan.io/address/0x16bc554e4ae25282b04c6dc825699a1302260745#contracts