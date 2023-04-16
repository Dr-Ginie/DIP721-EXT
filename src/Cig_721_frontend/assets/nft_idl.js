const nftIdl = ({ IDL }) => {
  const CollectionRequest = IDL.Record({
    'collectionCreator' : IDL.Principal,
    'external_url' : IDL.Text,
    'profileImage' : IDL.Vec(IDL.Nat8),
    'name' : IDL.Text,
    'description' : IDL.Text,
    'canvasHeight' : IDL.Nat32,
    'bannerImage' : IDL.Vec(IDL.Nat8),
    'canvasWidth' : IDL.Nat32,
    'royalty' : IDL.Float64,
  });
  const Value = IDL.Variant({
    'float' : IDL.Float64,
    'text' : IDL.Text,
    'number' : IDL.Int,
  });
  const Layer = IDL.Record({
    'contentType' : IDL.Text,
    'value' : IDL.Vec(IDL.Nat8),
  });
  const Attribute = IDL.Record({
    'weight' : IDL.Nat32,
    'trait_type' : IDL.Text,
    'value' : Value,
    'layer' : IDL.Opt(Layer),
    'display_type' : IDL.Opt(IDL.Text),
  });
  const WhiteList = IDL.Record({
    'title' : IDL.Text,
    'duration' : IDL.Nat,
    'value' : IDL.Vec(IDL.Principal),
    'description' : IDL.Text,
  });
  const Token__1 = IDL.Variant({
    'EXT' : IDL.Text,
    'IRC2' : IDL.Text,
    'Dip20' : IDL.Text,
    'Cig20' : IDL.Text,
  });
  const AuctionRequest = IDL.Record({
    'token' : Token__1,
    'duration' : IDL.Nat,
    'mintId' : IDL.Nat32,
    'amount' : IDL.Nat,
  });
  const Metadata = IDL.Record({
    'data' : IDL.Vec(IDL.Nat8),
    'mintId' : IDL.Nat32,
  });
  const Time = IDL.Int;
  const Auction = IDL.Record({
    'end' : Time,
    'token' : Token__1,
    'mintId' : IDL.Nat32,
    'amount' : IDL.Nat,
  });
  const Token = IDL.Variant({
    'EXT' : IDL.Text,
    'IRC2' : IDL.Text,
    'Dip20' : IDL.Text,
    'Cig20' : IDL.Text,
  });
  const Offer__2 = IDL.Record({
    'token' : Token,
    'mintId' : IDL.Nat32,
    'seller' : IDL.Principal,
    'expiration' : IDL.Opt(Time),
    'buyer' : IDL.Principal,
    'offerId' : IDL.Nat32,
    'amount' : IDL.Nat,
  });
  const Bid = IDL.Record({ 'offer' : Offer__2, 'owner' : IDL.Principal });
  const Offer = IDL.Record({
    'token' : Token,
    'mintId' : IDL.Nat32,
    'seller' : IDL.Principal,
    'expiration' : IDL.Opt(Time),
    'buyer' : IDL.Principal,
    'offerId' : IDL.Nat32,
    'amount' : IDL.Nat,
  });
  const Offer__1 = IDL.Record({
    'token' : Token,
    'mintId' : IDL.Nat32,
    'seller' : IDL.Principal,
    'expiration' : IDL.Opt(Time),
    'buyer' : IDL.Principal,
    'offerId' : IDL.Nat32,
    'amount' : IDL.Nat,
  });
  const Price = IDL.Record({ 'offer' : Offer__1, 'timeStamp' : Time });
  const OfferRequest = IDL.Record({
    'token' : Token,
    'mintId' : IDL.Nat32,
    'expiration' : IDL.Opt(Time),
    'amount' : IDL.Nat,
  });
  const HeaderField = IDL.Tuple(IDL.Text, IDL.Text);
  const Request = IDL.Record({
    'url' : IDL.Text,
    'method' : IDL.Text,
    'body' : IDL.Vec(IDL.Nat8),
    'headers' : IDL.Vec(HeaderField),
  });
  const StreamingCallbackToken = IDL.Record({
    'key' : IDL.Nat32,
    'sha256' : IDL.Opt(IDL.Vec(IDL.Nat8)),
    'index' : IDL.Nat32,
    'content_encoding' : IDL.Text,
  });
  const StreamingCallbackResponse = IDL.Record({
    'token' : IDL.Opt(StreamingCallbackToken),
    'body' : IDL.Vec(IDL.Nat8),
  });
  const StreamingCallback = IDL.Func(
      [StreamingCallbackToken],
      [StreamingCallbackResponse],
      ['query'],
    );
  const StreamingStrategy = IDL.Variant({
    'Callback' : IDL.Record({
      'token' : StreamingCallbackToken,
      'callback' : StreamingCallback,
    }),
  });
  const Response = IDL.Record({
    'body' : IDL.Vec(IDL.Nat8),
    'headers' : IDL.Vec(HeaderField),
    'streaming_strategy' : IDL.Opt(StreamingStrategy),
    'status_code' : IDL.Nat16,
  });
  const Cig721 = IDL.Service({
    'acceptOffer' : IDL.Func([IDL.Nat32, IDL.Nat32], [IDL.Nat32], []),
    'addAttribute' : IDL.Func([IDL.Nat32, IDL.Vec(Attribute)], [], []),
    'addWhiteList' : IDL.Func([WhiteList], [WhiteList], []),
    'allowance' : IDL.Func([IDL.Principal, IDL.Nat32], [IDL.Bool], []),
    'approve' : IDL.Func([IDL.Principal, IDL.Nat32], [], []),
    'auction' : IDL.Func([AuctionRequest], [], []),
    'balance' : IDL.Func([IDL.Principal], [IDL.Vec(Metadata)], ['query']),
    'bid' : IDL.Func([IDL.Nat, IDL.Nat32], [], []),
    'bulkMint' : IDL.Func([IDL.Nat32, IDL.Principal], [IDL.Vec(IDL.Nat32)], []),
    'buy' : IDL.Func([IDL.Nat32], [IDL.Nat32], []),
    'fetchAttributes' : IDL.Func([], [IDL.Vec(IDL.Vec(Attribute))], ['query']),
    'fetchAuctions' : IDL.Func([], [IDL.Vec(Auction)], ['query']),
    'fetchBids' : IDL.Func([IDL.Nat32], [IDL.Vec(Bid)], ['query']),
    'fetchOffers' : IDL.Func([IDL.Nat32], [IDL.Vec(Offer)], ['query']),
    'fetchOwners' : IDL.Func(
        [IDL.Vec(IDL.Nat32)],
        [
          IDL.Vec(
            IDL.Record({ 'owner' : IDL.Principal, 'mintId' : IDL.Nat32 })
          ),
        ],
        ['query'],
      ),
    'fetchPriceHistory' : IDL.Func([IDL.Nat32], [IDL.Vec(Price)], ['query']),
    'fetchSales' : IDL.Func([], [IDL.Vec(OfferRequest)], ['query']),
    'fetchWhiteList' : IDL.Func([], [IDL.Vec(WhiteList)], ['query']),
    'getAttribute' : IDL.Func([IDL.Nat32], [IDL.Vec(Attribute)], ['query']),
    'getCollectionCreator' : IDL.Func([], [IDL.Principal], ['query']),
    'getCollectionOwner' : IDL.Func([], [IDL.Principal], ['query']),
    'getCurrentWhiteList' : IDL.Func([], [WhiteList], ['query']),
    'getCycles' : IDL.Func([], [IDL.Nat], ['query']),
    'getData' : IDL.Func([IDL.Nat32], [Metadata], ['query']),
    'getDescription' : IDL.Func([], [IDL.Text], ['query']),
    'getHeapSize' : IDL.Func([], [IDL.Nat], ['query']),
    'getMemorySize' : IDL.Func([], [IDL.Nat], ['query']),
    'getMintCount' : IDL.Func([], [IDL.Nat32], ['query']),
    'getName' : IDL.Func([], [IDL.Text], ['query']),
    'getOwner' : IDL.Func([IDL.Nat32], [IDL.Principal], ['query']),
    'getRoyalty' : IDL.Func([], [IDL.Float64], ['query']),
    'getWinningBid' : IDL.Func([IDL.Nat32], [IDL.Opt(Offer)], ['query']),
    'http_request' : IDL.Func([Request], [Response], ['query']),
    'makeOffer' : IDL.Func([OfferRequest], [IDL.Nat32], []),
    'mint' : IDL.Func([IDL.Principal], [IDL.Nat32], []),
    'ownerDistribution' : IDL.Func([IDL.Nat, IDL.Nat], [IDL.Nat32], ['query']),
    'removeAttribute' : IDL.Func([IDL.Nat32], [], []),
    'sell' : IDL.Func([OfferRequest], [], []),
    'setMintPrice' : IDL.Func([IDL.Nat], [], []),
    'startMint' : IDL.Func([IDL.Nat], [], []),
    'transfer' : IDL.Func([IDL.Principal, IDL.Nat32], [], []),
    'transferFrom' : IDL.Func(
        [IDL.Principal, IDL.Principal, IDL.Nat32],
        [],
        [],
      ),
    'wallet_receive' : IDL.Func(
        [],
        [IDL.Record({ 'accepted' : IDL.Nat64 })],
        [],
      ),
  });
  return Cig721;
};
