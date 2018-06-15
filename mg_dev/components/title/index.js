//title组件

/* 
  用于每个模块上的标题标题 以及按钮
  eg:<Title
        title="管理员类别"
        titleBtn={[
          { type: "primary", btnTitle: "添加" },
          { type: "primary", btnTitle: "添加" }
        ]}
      />
*/
import React from "react";

import { Layout, Button, Row, Col, Divider } from "antd";

class Title extends React.Component {
  render() {
    return (
      <div id="title">
        <Layout style={{ backgroundColor: "rgba(0,0,0,0)" }}>
          <Row type="flex" justify="space-between">
            <Col>
              <h2>{this.props.title}</h2>
            </Col>
            <Col>
              {this.props.titleBtn &&
                this.props.titleBtn.length > 0 &&
                this.props.titleBtn.map((item, index) => (
                  <Button
                    key={index}
                    type={item.type}
                    onClick={item.clickEvent}
                    style={{ marginRight: "20px" }}
                  >
                    {item.btnTitle}
                  </Button>
                ))}
            </Col>
          </Row>
        </Layout>
        <Divider />
      </div>
    );
  }
}

export default Title;
