"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.init = exports.idlFactory = void 0;
var idlFactory = function (_a) {
    var IDL = _a.IDL;
    var WhiteList = IDL.Record({
        'title': IDL.Text,
        'duration': IDL.Nat,
        'value': IDL.Vec(IDL.Principal),
        'description': IDL.Text,
    });
    var Token__1 = IDL.Variant({
        'EXT': IDL.Text,
        'IRC2': IDL.Text,
        'Dip20': IDL.Text,
        'Dip20_EXT': IDL.Text,
    });
    var AuctionRequest = IDL.Record({
        'icp': IDL.Nat,
        'token': Token__1,
        'duration': IDL.Nat,
        'mintId': IDL.Nat32,
        'amount': IDL.Nat,
    });
    var Metadata = IDL.Record({
        'data': IDL.Vec(IDL.Nat8),
        'mintId': IDL.Nat32,
    });
    var Token = IDL.Variant({
        'EXT': IDL.Text,
        'IRC2': IDL.Text,
        'Dip20': IDL.Text,
        'Dip20_EXT': IDL.Text,
    });
    var Time = IDL.Int;
    var OfferRequest = IDL.Record({
        'icp': IDL.Nat,
        'token': IDL.Opt(Token),
        'mintId': IDL.Nat32,
        'expiration': IDL.Opt(Time),
        'amount': IDL.Nat,
    });
    var Auction = IDL.Record({
        'end': Time,
        'icp': IDL.Nat,
        'token': Token__1,
        'mintId': IDL.Nat32,
        'amount': IDL.Nat,
    });
    var Offer__2 = IDL.Record({
        'icp': IDL.Nat,
        'token': IDL.Opt(Token),
        'mintId': IDL.Nat32,
        'seller': IDL.Principal,
        'expiration': IDL.Opt(Time),
        'buyer': IDL.Principal,
        'offerId': IDL.Nat32,
        'amount': IDL.Nat,
    });
    var Bid = IDL.Record({ 'offer': Offer__2, 'owner': IDL.Principal });
    var Offer = IDL.Record({
        'icp': IDL.Nat,
        'token': IDL.Opt(Token),
        'mintId': IDL.Nat32,
        'seller': IDL.Principal,
        'expiration': IDL.Opt(Time),
        'buyer': IDL.Principal,
        'offerId': IDL.Nat32,
        'amount': IDL.Nat,
    });
    var Offer__1 = IDL.Record({
        'icp': IDL.Nat,
        'token': IDL.Opt(Token),
        'mintId': IDL.Nat32,
        'seller': IDL.Principal,
        'expiration': IDL.Opt(Time),
        'buyer': IDL.Principal,
        'offerId': IDL.Nat32,
        'amount': IDL.Nat,
    });
    var Price = IDL.Record({ 'offer': Offer__1, 'timeStamp': Time });
    var Transaction = IDL.Record({
        'to': IDL.Principal,
        'from': IDL.Principal,
        'createdAt': Time,
        'mintId': IDL.Nat32,
    });
    var HeaderField = IDL.Tuple(IDL.Text, IDL.Text);
    var Request = IDL.Record({
        'url': IDL.Text,
        'method': IDL.Text,
        'body': IDL.Vec(IDL.Nat8),
        'headers': IDL.Vec(HeaderField),
    });
    var StreamingCallbackToken = IDL.Record({
        'key': IDL.Nat32,
        'sha256': IDL.Opt(IDL.Vec(IDL.Nat8)),
        'index': IDL.Nat32,
        'content_encoding': IDL.Text,
    });
    var StreamingCallbackResponse = IDL.Record({
        'token': IDL.Opt(StreamingCallbackToken),
        'body': IDL.Vec(IDL.Nat8),
    });
    var StreamingCallback = IDL.Func([StreamingCallbackToken], [StreamingCallbackResponse], ['query']);
    var StreamingStrategy = IDL.Variant({
        'Callback': IDL.Record({
            'token': StreamingCallbackToken,
            'callback': StreamingCallback,
        }),
    });
    var Response = IDL.Record({
        'body': IDL.Vec(IDL.Nat8),
        'headers': IDL.Vec(HeaderField),
        'streaming_strategy': IDL.Opt(StreamingStrategy),
        'status_code': IDL.Nat16,
    });
    var Dip721 = IDL.Service({
        'acceptOffer': IDL.Func([IDL.Nat32, IDL.Nat32], [IDL.Nat32], []),
        'addWhiteList': IDL.Func([WhiteList], [WhiteList], []),
        'allowance': IDL.Func([IDL.Principal, IDL.Nat32], [IDL.Bool], []),
        'approve': IDL.Func([IDL.Principal, IDL.Nat32], [], []),
        'auction': IDL.Func([AuctionRequest], [], []),
        'balance': IDL.Func([IDL.Principal], [IDL.Vec(Metadata)], ['query']),
        'balance_of': IDL.Func([IDL.Principal], [IDL.Vec(IDL.Nat32)], ['query']),
        'bid': IDL.Func([IDL.Nat, IDL.Nat32], [], []),
        'bulkBuy': IDL.Func([IDL.Vec(IDL.Nat32)], [IDL.Vec(IDL.Nat32)], []),
        'bulkMint': IDL.Func([IDL.Vec(IDL.Vec(IDL.Nat8)), IDL.Principal], [IDL.Vec(IDL.Nat32)], []),
        'bulkSell': IDL.Func([IDL.Vec(OfferRequest)], [], []),
        'buy': IDL.Func([IDL.Nat32], [IDL.Nat32], []),
        'claimSales': IDL.Func([], [], []),
        'fetchAuctions': IDL.Func([], [IDL.Vec(Auction)], ['query']),
        'fetchBids': IDL.Func([IDL.Nat32], [IDL.Vec(Bid)], ['query']),
        'fetchHolders': IDL.Func([], [IDL.Vec(IDL.Principal)], ['query']),
        'fetchOffers': IDL.Func([IDL.Nat32], [IDL.Vec(Offer)], ['query']),
        'fetchOwners': IDL.Func([IDL.Vec(IDL.Nat32)], [
            IDL.Vec(IDL.Record({ 'owner': IDL.Principal, 'mintId': IDL.Nat32 })),
        ], ['query']),
        'fetchPriceHistory': IDL.Func([IDL.Opt(Time), IDL.Nat32], [IDL.Vec(Price)], ['query']),
        'fetchSales': IDL.Func([], [IDL.Vec(OfferRequest)], ['query']),
        'fetchTransactions': IDL.Func([IDL.Nat, IDL.Nat], [IDL.Vec(IDL.Tuple(IDL.Nat32, Transaction))], ['query']),
        'fetchWhiteList': IDL.Func([], [IDL.Vec(WhiteList)], ['query']),
        'getActiveBidCount': IDL.Func([], [IDL.Nat32], ['query']),
        'getActiveSaleCount': IDL.Func([], [IDL.Nat32], ['query']),
        'getClaim': IDL.Func([], [IDL.Nat], ['query']),
        'getCollectionCreator': IDL.Func([], [IDL.Principal], ['query']),
        'getCollectionOwner': IDL.Func([], [IDL.Principal], ['query']),
        'getCurrentWhiteList': IDL.Func([], [WhiteList], ['query']),
        'getCycles': IDL.Func([], [IDL.Nat], ['query']),
        'getData': IDL.Func([IDL.Nat32], [Metadata], ['query']),
        'getDescription': IDL.Func([], [IDL.Text], ['query']),
        'getHeapSize': IDL.Func([], [IDL.Nat], ['query']),
        'getMemorySize': IDL.Func([], [IDL.Nat], ['query']),
        'getMintCount': IDL.Func([], [IDL.Nat32], ['query']),
        'getName': IDL.Func([], [IDL.Text], ['query']),
        'getOfferCount': IDL.Func([], [IDL.Nat32], ['query']),
        'getOwner': IDL.Func([IDL.Nat32], [IDL.Principal], ['query']),
        'getRoyalty': IDL.Func([], [IDL.Float64], ['query']),
        'getSaleHistroyCount': IDL.Func([], [IDL.Nat32], ['query']),
        'getTransactionCount': IDL.Func([], [IDL.Nat32], ['query']),
        'getWinningBid': IDL.Func([IDL.Nat32], [IDL.Opt(Offer)], ['query']),
        'http_request': IDL.Func([Request], [Response], ['query']),
        'makeOffer': IDL.Func([OfferRequest], [IDL.Nat32], []),
        'mint': IDL.Func([IDL.Vec(IDL.Nat8), IDL.Principal], [IDL.Nat32], []),
        'ownerDistribution': IDL.Func([IDL.Nat, IDL.Nat], [IDL.Nat32], ['query']),
        'putBlob': IDL.Func([IDL.Vec(IDL.Nat8)], [IDL.Nat32], []),
        'sell': IDL.Func([OfferRequest], [], []),
        'startMint': IDL.Func([IDL.Nat], [], []),
        'transfer': IDL.Func([IDL.Principal, IDL.Nat32], [], []),
        'transferFrom': IDL.Func([IDL.Principal, IDL.Principal, IDL.Nat32], [], []),
        'wallet_receive': IDL.Func([], [IDL.Record({ 'accepted': IDL.Nat64 })], []),
    });
    return Dip721;
};
exports.idlFactory = idlFactory;
var init = function (_a) {
    var IDL = _a.IDL;
    return [];
};
exports.init = init;
