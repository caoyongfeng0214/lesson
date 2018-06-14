import React from "react";
import { Table, Button, Popconfirm, Modal, Input, Alert } from "antd";

//ajax
import Axios from "axios";

//API
import API from "../../API";

//title
import Title from "../title";
//tableData
import TableData from "../../tableData";

class Category extends React.Component {
  constructor(props) {
    super(props);
    //table
    this.columns = [
      {
        title: "序号",
        dataIndex: "index",
        key: "index",
        align: "center",
        render: (text, record, index) => (
          <span>
            <span>{index + 1}</span>
          </span>
        )
      },
      {
        title: "类别名称",
        dataIndex: "name",
        key: "name",
        align: "center"
      },
      {
        title: "添加时间",
        dataIndex: "time",
        key: "time",
        align: "center"
      }
      // 暂不需要删除
      // {
      //   title: "操作",
      //   key: "action",
      //   align: "center",
      //   render: (text, record) => {
      //     return (
      //       <span>
      //         {record.state === false ? (
      //           this.state.CategoryData.length > 1 ? (
      //             <Popconfirm
      //               title="Sure to delete?"
      //               onConfirm={() => this.onDelete(record.id)}
      //             >
      //               <Button type="danger">删除</Button>
      //             </Popconfirm>
      //           ) : null
      //         ) : (
      //           "/"
      //         )}
      //       </span>
      //     );
      //   }
      // }
    ];

    this.state = {
      CategoryData: TableData.categoryData,
      nameDisabled: false,
      visible: false,
      confirmLoading: false,
      typeName: "",
      errorVisible: false,
      errorMsg: ""
    };
    this.addManager = this.addManager.bind(this);
    //暂时没有
    this.onDelete = this.onDelete.bind(this);
    this.handleUpdateCancel = this.handleUpdateCancel.bind(this);
    this.handleUpdateOk = this.handleUpdateOk.bind(this);
    this.handleTypeNameChange = this.handleTypeNameChange.bind(this);
  }

  //删除管理员类别
  onDelete(id) {
    const dataSource = [...this.state.CategoryData];
    this.setState({ CategoryData: dataSource.filter(item => item.id !== id) });
  }
  // 添加管理员类别
  addManager() {
    this.setState({
      visible: true
    });
  }
  //输入框监听事件
  handleTypeNameChange(e) {
    this.setState({ typeName: e.target.value });
  }
  //确认添加
  handleUpdateOk() {
    if (this.state.typeName !== "") {
      this.setState({
        nameDisabled: true,
        confirmLoading: true
      });
      const res = Axios.post(API.postUpsertType, { name: this.state.typeName });
      console.log(res);
      if (res.err === 0) {
        this.setState({
          visible: false,
          confirmLoading: false
        });
      } else {
        this.setState({
          errorVisible: true,
          errorMsg: res.msg
        });
      }
    } else {
      this.setState({
        errorVisible: true,
        errorMsg: "请输入类别名称"
      });
    }
  }
  //取消添加
  handleUpdateCancel() {
    this.setState({
      visible: false
    });
  }
  render() {
    const columns = this.columns;
    const {
      visible,
      confirmLoading,
      nameDisabled,
      typeName,
      errorVisible,
      errorMsg
    } = this.state;
    return (
      <div>
        <Title
          title="管理员类别"
          id="3"
          titleBtn={[
            {
              type: "primary",
              btnTitle: "添加",
              clickEvent: () => this.addManager()
            }
          ]}
        />
        <Table
          rowKey={record => record.id}
          columns={columns}
          dataSource={this.state.CategoryData}
        />
        {errorVisible && <Alert message={errorMsg} type="error" />}
        <Modal
          title="添加类别"
          visible={visible}
          onOk={this.handleUpdateOk}
          confirmLoading={confirmLoading}
          onCancel={this.handleUpdateCancel}
        >
          <p>
            <Input
              placeholder="请输入类别名称"
              disabled={nameDisabled}
              value={typeName}
              onChange={this.handleTypeNameChange}
            />
          </p>
        </Modal>
      </div>
    );
  }
}

export default Category;
