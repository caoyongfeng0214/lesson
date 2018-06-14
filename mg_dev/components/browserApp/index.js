import React from "react";
import { BrowserRouter, Route } from "react-router-dom";

import App from "../app";

class Browswer extends React.Component {
  render() {
    return (
      <BrowserRouter>
        <Route component={App} />
      </BrowserRouter>
    );
  }
}

export default Browswer;
