const registryIDL = ({ IDL }) => {
  const ContentStatus = IDL.Variant({
    'new' : IDL.Null,
    'approved' : IDL.Null,
    'rejected' : IDL.Null,
  });
  const ViolatedRules = IDL.Record({
    'id' : IDL.Text,
    'rejectionCount' : IDL.Nat,
  });
  const ContentResult = IDL.Record({
    'status' : ContentStatus,
    'approvedCount' : IDL.Nat,
    'sourceId' : IDL.Text,
    'violatedRules' : IDL.Vec(ViolatedRules),
    'rejectedCount' : IDL.Nat,
  });
  const Ad = IDL.Record({
    'owner' : IDL.Principal,
    'name' : IDL.Text,
    'amount' : IDL.Nat,
  });
  const TxReceipt = IDL.Variant({
    'Ok' : IDL.Nat,
    'Err' : IDL.Variant({
      'InsufficientAllowance' : IDL.Null,
      'InsufficientBalance' : IDL.Null,
      'ActiveProposal' : IDL.Null,
      'ErrorOperationStyle' : IDL.Null,
      'Unauthorized' : IDL.Null,
      'LedgerTrap' : IDL.Null,
      'ErrorTo' : IDL.Null,
      'Other' : IDL.Text,
      'BlockUsed' : IDL.Null,
      'AmountTooSmall' : IDL.Null,
    }),
  });
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
  const TeamMember = IDL.Record({
    'title' : IDL.Text,
    'social' : IDL.Text,
    'name' : IDL.Text,
    'description' : IDL.Text,
    'profileUrl' : IDL.Text,
  });
  const Category = IDL.Variant({
    'Art' : IDL.Null,
    'PFP' : IDL.Null,
    'Gaming' : IDL.Null,
    'Music' : IDL.Null,
    'Photography' : IDL.Null,
  });
  const Collection = IDL.Record({
    'name' : IDL.Text,
    'team' : IDL.Vec(TeamMember),
    'community' : IDL.Text,
    'description' : IDL.Text,
    'spotlightUrl' : IDL.Text,
    'website' : IDL.Text,
    'canister' : IDL.Text,
    'category' : Category,
    'bannerUrl' : IDL.Text,
  });
  const Category__1 = IDL.Variant({
    'Art' : IDL.Null,
    'PFP' : IDL.Null,
    'Gaming' : IDL.Null,
    'Music' : IDL.Null,
    'Photography' : IDL.Null,
  });
  const NFT_Registry = IDL.Service({
    'ModclubCallback' : IDL.Func([ContentResult], [], ['oneway']),
    'bannerBid' : IDL.Func([Ad], [TxReceipt], []),
    'createCollection' : IDL.Func([CollectionRequest], [IDL.Text], []),
    'fetchCollections' : IDL.Func([], [IDL.Vec(Collection)], ['query']),
    'fetchCollectionsByCategory' : IDL.Func(
        [Category__1],
        [IDL.Vec(Collection)],
        ['query'],
      ),
    'fetchSpotlightBids' : IDL.Func([], [IDL.Vec(Ad)], ['query']),
    'fetchSpotlights' : IDL.Func([Category__1], [IDL.Vec(Ad)], ['query']),
    'getBNannerAdBid' : IDL.Func([], [IDL.Opt(Ad)], ['query']),
    'getCollection' : IDL.Func([IDL.Text], [IDL.Opt(Collection)], ['query']),
    'getCycles' : IDL.Func([], [IDL.Nat], ['query']),
    'getHeapSize' : IDL.Func([], [IDL.Nat], ['query']),
    'getMainBannerAd' : IDL.Func([], [IDL.Opt(Ad)], ['query']),
    'getMemorySize' : IDL.Func([], [IDL.Nat], ['query']),
    'getTestResult' : IDL.Func([], [IDL.Opt(ContentResult)], ['query']),
    'getTimerId' : IDL.Func([], [IDL.Opt(IDL.Nat)], ['query']),
    'registerCollection' : IDL.Func([Collection], [IDL.Text], []),
    'setSubscribeCallback' : IDL.Func([], [], []),
    'spotlightBid' : IDL.Func([Ad], [TxReceipt], []),
    'startAdTimer' : IDL.Func([], [], []),
    'testRegisterCollection' : IDL.Func([Collection], [IDL.Text], []),
    'testSubmitContentToModclub' : IDL.Func([IDL.Text], [IDL.Text], []),
    'updateModSettings' : IDL.Func([], [], []),
    'updateRules' : IDL.Func([], [], []),
  });
  return NFT_Registry;
};
