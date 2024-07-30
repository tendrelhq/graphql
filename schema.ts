interface Node {
  id: string;
}

type PageInfo = {
  hasNextPage: boolean;
  hasPrevPage: boolean;
  startCursor?: string;
  endCursor?: string;
};

type Connection<T extends Node> = {
  edges: Edge<T>[];
  pageInfo: PageInfo;
};

type Edge<T extends Node> = {
  node: T;
};

/////
//
// This would be application defined
//
/////

interface Worker extends Node {
  displayName?: string;
  user: User;
}

interface User extends Node {
  firstName: string;
  lastName: string;
  displayName?: string;
}
