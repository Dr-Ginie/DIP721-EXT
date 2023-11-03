import type {ActorMethod} from "@dfinity/agent";
import type {Principal} from "@dfinity/principal";

export interface Auction {
  end: Time;
  icp: bigint;
  token: Token__1;
  mintId: number;
  amount: bigint;
}
export interface AuctionRequest {
  icp: bigint;
  token: Token__1;
  duration: bigint;
  mintId: number;
  amount: bigint;
}
export interface Bid {
  offer: Offer__2;
  owner: Principal;
}
export interface CollectionRequest {
  collectionCreator: string;
  external_url: string;
  profileImage: Uint8Array | number[];
  name: string;
  description: string;
  bannerImage: Uint8Array | number[];
  royalty: number;
}
export interface Dip721 {
  acceptOffer: ActorMethod<[number, number], number>;
  addWhiteList: ActorMethod<[WhiteList], WhiteList>;
  allowance: ActorMethod<[Principal, number], boolean>;
  approve: ActorMethod<[Principal, number], undefined>;
  auction: ActorMethod<[AuctionRequest], undefined>;
  balance: ActorMethod<[Principal], Array<Metadata>>;
  balance_of: ActorMethod<[Principal], Uint32Array | number[]>;
  bid: ActorMethod<[bigint, number], undefined>;
  bulkBuy: ActorMethod<[Uint32Array | number[]], Uint32Array | number[]>;
  bulkMint: ActorMethod<[Array<Uint8Array | number[]>, Principal], Uint32Array | number[]>;
  bulkSell: ActorMethod<[Array<OfferRequest>], undefined>;
  buy: ActorMethod<[number], number>;
  claimSales: ActorMethod<[], undefined>;
  fetchAuctions: ActorMethod<[], Array<Auction>>;
  fetchBids: ActorMethod<[number], Array<Bid>>;
  fetchHolders: ActorMethod<[], Array<Principal>>;
  fetchOffers: ActorMethod<[number], Array<Offer>>;
  fetchOwners: ActorMethod<[Uint32Array | number[]], Array<{owner: Principal; mintId: number}>>;
  fetchPriceHistory: ActorMethod<[[] | [Time], number], Array<Price>>;
  fetchSales: ActorMethod<[], Array<OfferRequest>>;
  fetchTransactions: ActorMethod<[bigint, bigint], Array<[number, Transaction]>>;
  fetchWhiteList: ActorMethod<[], Array<WhiteList>>;
  getActiveBidCount: ActorMethod<[], number>;
  getActiveSaleCount: ActorMethod<[], number>;
  getClaim: ActorMethod<[], bigint>;
  getCollectionCreator: ActorMethod<[], Principal>;
  getCollectionOwner: ActorMethod<[], Principal>;
  getCurrentWhiteList: ActorMethod<[], WhiteList>;
  getCycles: ActorMethod<[], bigint>;
  getData: ActorMethod<[number], Metadata>;
  getDescription: ActorMethod<[], string>;
  getHeapSize: ActorMethod<[], bigint>;
  getMemorySize: ActorMethod<[], bigint>;
  getMintCount: ActorMethod<[], number>;
  getName: ActorMethod<[], string>;
  getOfferCount: ActorMethod<[], number>;
  getOwner: ActorMethod<[number], Principal>;
  getRoyalty: ActorMethod<[], number>;
  getSaleHistroyCount: ActorMethod<[], number>;
  getTransactionCount: ActorMethod<[], number>;
  getWinningBid: ActorMethod<[number], [] | [Offer]>;
  http_request: ActorMethod<[Request], Response>;
  makeOffer: ActorMethod<[OfferRequest], number>;
  mint: ActorMethod<[Uint8Array | number[], Principal], number>;
  ownerDistribution: ActorMethod<[bigint, bigint], number>;
  putBlob: ActorMethod<[Uint8Array | number[]], number>;
  sell: ActorMethod<[OfferRequest], undefined>;
  startMint: ActorMethod<[bigint], undefined>;
  transfer: ActorMethod<[Principal, number], undefined>;
  transferFrom: ActorMethod<[Principal, Principal, number], undefined>;
  wallet_receive: ActorMethod<[], {accepted: bigint}>;
}
export type HeaderField = [string, string];
export interface Metadata {
  data: Uint8Array | number[];
  mintId: number;
}
export interface Offer {
  icp: bigint;
  token: [] | [Token];
  mintId: number;
  seller: Principal;
  expiration: [] | [Time];
  buyer: Principal;
  offerId: number;
  amount: bigint;
}
export interface OfferRequest {
  icp: bigint;
  token: [] | [Token];
  mintId: number;
  expiration: [] | [Time];
  amount: bigint;
}
export interface Offer__1 {
  icp: bigint;
  token: [] | [Token];
  mintId: number;
  seller: Principal;
  expiration: [] | [Time];
  buyer: Principal;
  offerId: number;
  amount: bigint;
}
export interface Offer__2 {
  icp: bigint;
  token: [] | [Token];
  mintId: number;
  seller: Principal;
  expiration: [] | [Time];
  buyer: Principal;
  offerId: number;
  amount: bigint;
}
export interface Price {
  offer: Offer__1;
  timeStamp: Time;
}
export interface Request {
  url: string;
  method: string;
  body: Uint8Array | number[];
  headers: Array<HeaderField>;
}
export interface Response {
  body: Uint8Array | number[];
  headers: Array<HeaderField>;
  streaming_strategy: [] | [StreamingStrategy];
  status_code: number;
}
export type StreamingCallback = ActorMethod<[StreamingCallbackToken], StreamingCallbackResponse>;
export interface StreamingCallbackResponse {
  token: [] | [StreamingCallbackToken];
  body: Uint8Array | number[];
}
export interface StreamingCallbackToken {
  key: number;
  sha256: [] | [Uint8Array | number[]];
  index: number;
  content_encoding: string;
}
export type StreamingStrategy = {
  Callback: {
    token: StreamingCallbackToken;
    callback: StreamingCallback;
  };
};
export type Time = bigint;
export type Token = {EXT: string} | {IRC2: string} | {Dip20: string} | {Dip20_EXT: string};
export type Token__1 = {EXT: string} | {IRC2: string} | {Dip20: string} | {Dip20_EXT: string};
export interface Transaction {
  to: Principal;
  from: Principal;
  createdAt: Time;
  mintId: number;
}
export interface WhiteList {
  title: string;
  duration: bigint;
  value: Array<Principal>;
  description: string;
}
export interface _SERVICE extends Dip721 {}
