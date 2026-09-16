/*
 *  Copyright 2026  Werner Lechner <werner.lechner@lehklu.at>
 */

const GET_CURRENT_DESKNO = function($VirtualDesktopInfo) {
  const currentId = $VirtualDesktopInfo.currentDesktop;
  const ids = $VirtualDesktopInfo.desktopIds || [];
  const idx = ids.indexOf(currentId);
  return idx >= 0 ? idx + 1 : 0;
};

const parseConfiguration = function(raw) {
  if (raw) {
    try {
      var parsed = JSON.parse(raw);
      if (parsed && typeof parsed === "object") {
        return parsed;
      }
    } catch (e) {}
  }
  return {};
};

const getConfig = function(parsedConfiguration, plasmoidConfiguration, key, fallback) {
  if (parsedConfiguration && parsedConfiguration[key] !== undefined && parsedConfiguration[key] !== null) {
    return parsedConfiguration[key];
  }
  var val = plasmoidConfiguration ? plasmoidConfiguration[key] : undefined;
  return val !== undefined && val !== null ? val : fallback;
};

const getDesktopConfig = function(parsedConfiguration, plasmoidConfiguration, listName, deskIndex, fallback) {
  var values = parsedConfiguration ? parsedConfiguration[listName] : undefined;
  if (typeof values === "string") {
    try {
      values = JSON.parse(values);
    } catch (e) {}
  }
  if (Array.isArray(values) && deskIndex > 0 && deskIndex < values.length &&
      values[deskIndex] !== undefined && values[deskIndex] !== null && values[deskIndex] !== "") {
    return values[deskIndex];
  }
  if (Array.isArray(values) && values.length > 0 &&
      values[0] !== undefined && values[0] !== null && values[0] !== "") {
    return values[0];
  }
  var stored = plasmoidConfiguration ? plasmoidConfiguration[listName] : undefined;
  if (stored) {
    try {
      var legacyValues = (typeof stored === "string") ? JSON.parse(stored) : stored;
      if (Array.isArray(legacyValues) && deskIndex > 0 && deskIndex < legacyValues.length &&
          legacyValues[deskIndex] !== undefined && legacyValues[deskIndex] !== null && legacyValues[deskIndex] !== "") {
        return legacyValues[deskIndex];
      }
      if (Array.isArray(legacyValues) && legacyValues.length > 0 &&
          legacyValues[0] !== undefined && legacyValues[0] !== null && legacyValues[0] !== "") {
        return legacyValues[0];
      }
    } catch (e) {}
  }
  return fallback;
};

const handleOnDesktopChanged = function(root, desktopInfo, newDeskNo) {
  if (newDeskNo < 1) {
    return;
  }
  root._currentDesktopNo = newDeskNo;
  var names = desktopInfo.desktopNames || [];
  root._currentDesktopName = (names && names[newDeskNo - 1])
      ? names[newDeskNo - 1]
      : qsTr("Desktop %1").arg(newDeskNo);
};

const sectionOrderIndex = function(sectionOrder, section, fallback) {
  var order = String(sectionOrder || "date,desktopName,desktopNumber").split(",");
  var index = order.indexOf(section);
  return index >= 0 ? index : fallback;
};

const totalSectionsWeight = function(sectionDateWidthWeight, sectionDesktopNameWidthWeight, sectionDesktopNumberWidthWeight) {
  var wDate = sectionDateWidthWeight > 0 ? sectionDateWidthWeight : 0;
  var wName = sectionDesktopNameWidthWeight > 0 ? sectionDesktopNameWidthWeight : 0;
  var wNum = sectionDesktopNumberWidthWeight > 0 ? sectionDesktopNumberWidthWeight : 0;
  return wDate + wName + wNum;
};

const sectionWidth = function(contentWidth, totalWeight, weight) {
  return totalWeight > 0 && weight > 0 ? contentWidth * weight / totalWeight : 0;
};

const sectionOffset = function(contentWidth, totalWeight, dateOrder, nameOrder, numberOrder, dateWeight, nameWeight, numberWeight, targetOrder) {
  if (totalWeight <= 0) {
    return 0;
  }
  var offsetWeight = 0;
  if (dateOrder < targetOrder && dateWeight > 0) {
    offsetWeight += dateWeight;
  }
  if (nameOrder < targetOrder && nameWeight > 0) {
    offsetWeight += nameWeight;
  }
  if (numberOrder < targetOrder && numberWeight > 0) {
    offsetWeight += numberWeight;
  }
  return contentWidth * offsetWeight / totalWeight;
};

const ensureDesktopValue = function(list, desktopNo) {
  var idx = desktopNo;
  if (list && idx > 0 && idx < list.length && list[idx] !== undefined && list[idx] !== null && list[idx] !== "") {
    return list[idx];
  }
  return (list && list.length > 0) ? list[0] : undefined;
};

const ensureDesktopProperty = function(root, propName, desktopNo) {
  return ensureDesktopValue(root[propName], desktopNo);
};

const syncListFromConfig = function(root, propName, jsonStrOrArray) {
  if (jsonStrOrArray === undefined || jsonStrOrArray === null || jsonStrOrArray === "") {
    return;
  }
  if (Array.isArray(jsonStrOrArray)) {
    if (jsonStrOrArray.length > 0) {
      root[propName] = jsonStrOrArray.slice();
    }
    return;
  }
  if (typeof jsonStrOrArray === "string") {
    try {
      var parsed = JSON.parse(jsonStrOrArray);
      if (Array.isArray(parsed) && parsed.length > 0) {
        root[propName] = parsed;
        return;
      }
    } catch (e) {}
    root[propName] = [jsonStrOrArray];
    return;
  }
  root[propName] = [jsonStrOrArray];
};

const saveConfiguration = function(root) {
  var configObj = {
    heightWidthRatio: root.heightWidthRatio,
    sectionOrder: root._sectionOrder,
    sectionDateWidthWeight: root.sectionDateWidthWeight,
    sectionDesktopNameWidthWeight: root.sectionDesktopNameWidthWeight,
    sectionDesktopNumberWidthWeight: root.sectionDesktopNumberWidthWeight
  };
  var styleProps = root._STYLE_PROPERTIES || [];
  for (var l = 0; l < styleProps.length; ++l) {
    var propName = styleProps[l].prop;
    var valList = root[propName];
    if (Array.isArray(valList)) {
      configObj[propName] = valList.map(function(v) {
        return (v && typeof v === "object" && v.toString) ? v.toString() : v;
      });
    } else {
      configObj[propName] = valList;
    }
  }
  var jsonStr = JSON.stringify(configObj);
  if (root.cfg_desktopindikator01 !== jsonStr) {
    root._isSaving = true;
    root.cfg_desktopindikator01 = jsonStr;
    root._isSaving = false;
  }
};

const sectionWidthValue = function(root, key) {
  if (key === "date") return root.sectionDateWidthWeight;
  if (key === "desktopName") return root.sectionDesktopNameWidthWeight;
  return root.sectionDesktopNumberWidthWeight;
};

const setSectionWidth = function(root, key, value) {
  if (key === "date") root.sectionDateWidthWeight = value;
  else if (key === "desktopName") root.sectionDesktopNameWidthWeight = value;
  else root.sectionDesktopNumberWidthWeight = value;
  saveConfiguration(root);
};

const updateSectionOrder = function(sectionModel, root) {
  var order = [];
  for (var i = 0; i < sectionModel.count; ++i) {
    order.push(sectionModel.get(i).key);
  }
  root._sectionOrder = order.join(",");
  saveConfiguration(root);
};

const loadSectionOrder = function(root, sectionModel) {
  var savedOrder = String(root._sectionOrder || "date,desktopName,desktopNumber").split(",");
  var valid = ["date", "desktopName", "desktopNumber"];
  var ordered = [];
  for (var i = 0; i < savedOrder.length; ++i) {
    if (valid.indexOf(savedOrder[i]) >= 0 && ordered.indexOf(savedOrder[i]) < 0) {
      ordered.push(savedOrder[i]);
    }
  }
  for (var j = 0; j < valid.length; ++j) {
    if (ordered.indexOf(valid[j]) < 0) {
      ordered.push(valid[j]);
    }
  }
  for (var k = 0; k < ordered.length; ++k) {
    var currentIndex = -1;
    for (var n = 0; n < sectionModel.count; ++n) {
      if (sectionModel.get(n).key === ordered[k]) {
        currentIndex = n;
        break;
      }
    }
    if (currentIndex >= 0 && currentIndex !== k) {
      sectionModel.move(currentIndex, k, 1);
    }
  }
};

const loadConfiguration = function(root, jsonStr, plasmoidConfiguration) {
  var raw = jsonStr || root.cfg_desktopindikator01 || (plasmoidConfiguration && plasmoidConfiguration.desktopindikator01) || "";
  var configObj = {};
  if (raw) {
    try {
      configObj = JSON.parse(raw) || {};
    } catch (e) {}
  }

  if (configObj.heightWidthRatio !== undefined) {
    root.heightWidthRatio = configObj.heightWidthRatio;
  } else if (plasmoidConfiguration && plasmoidConfiguration.heightWidthRatio !== undefined) {
    root.heightWidthRatio = plasmoidConfiguration.heightWidthRatio;
  }

  if (configObj.sectionOrder !== undefined) {
    root._sectionOrder = configObj.sectionOrder;
  } else if (plasmoidConfiguration && plasmoidConfiguration.sectionOrder !== undefined) {
    root._sectionOrder = plasmoidConfiguration.sectionOrder;
  }

  if (configObj.sectionDateWidthWeight !== undefined) {
    root.sectionDateWidthWeight = configObj.sectionDateWidthWeight;
  } else if (plasmoidConfiguration && plasmoidConfiguration.sectionDateWidthWeight !== undefined) {
    root.sectionDateWidthWeight = plasmoidConfiguration.sectionDateWidthWeight;
  }

  if (configObj.sectionDesktopNameWidthWeight !== undefined) {
    root.sectionDesktopNameWidthWeight = configObj.sectionDesktopNameWidthWeight;
  } else if (plasmoidConfiguration && plasmoidConfiguration.sectionDesktopNameWidthWeight !== undefined) {
    root.sectionDesktopNameWidthWeight = plasmoidConfiguration.sectionDesktopNameWidthWeight;
  }

  if (configObj.sectionDesktopNumberWidthWeight !== undefined) {
    root.sectionDesktopNumberWidthWeight = configObj.sectionDesktopNumberWidthWeight;
  } else if (plasmoidConfiguration && plasmoidConfiguration.sectionDesktopNumberWidthWeight !== undefined) {
    root.sectionDesktopNumberWidthWeight = plasmoidConfiguration.sectionDesktopNumberWidthWeight;
  }

  var styleProps = root._STYLE_PROPERTIES || [];
  for (var l = 0; l < styleProps.length; ++l) {
    var propName = styleProps[l].prop;
    if (configObj[propName] !== undefined) {
      syncListFromConfig(root, propName, configObj[propName]);
    } else if (plasmoidConfiguration && plasmoidConfiguration[propName] !== undefined) {
      syncListFromConfig(root, propName, plasmoidConfiguration[propName]);
    }
  }

  if (root.loadSectionOrder) {
    root.loadSectionOrder();
  }
};

const setAt = function(list, index, value) {
  var copy = (list && Array.isArray(list)) ? list.slice() : [];
  var defaultVal = (copy.length > 0 && copy[0] !== undefined) ? copy[0] : value;
  while (copy.length <= index) {
    copy.push(defaultVal);
  }
  copy[index] = value;
  return copy;
};

const updateStyleProperty = function(root, linkToggleChecked, desktopModelCount, selectedDesktopNo, propName, value) {
  var stringVal = (value && typeof value === "object" && value.toString) ? value.toString() : value;
  if (linkToggleChecked) {
    var count = Math.max(desktopModelCount || 0, (root[propName] && root[propName].length ? root[propName].length - 1 : 0), 1);
    var arr = [];
    for (var i = 0; i <= count; ++i) {
      arr.push(stringVal);
    }
    root[propName] = arr;
  } else {
    root[propName] = setAt(root[propName], selectedDesktopNo, stringVal);
  }
  saveConfiguration(root);
};

const getDesktopStyle = function(root, idx) {
  var deskIdx = Math.max(0, idx);
  var result = { type: "DesktopIndicatorStyle" };
  var styleProps = root._STYLE_PROPERTIES || [];
  for (var i = 0; i < styleProps.length; ++i) {
    var item = styleProps[i];
    var val = ensureDesktopProperty(root, item.prop, deskIdx);
    result[item.key] = (val && typeof val === "object" && val.toString) ? val.toString() : val;
  }
  return result;
};

const applyStyleToAllDesktops = function(root, desktopModelCount, style) {
  if (!style) {
    return;
  }
  var count = Math.max(desktopModelCount || 0, 1);
  var styleProps = root._STYLE_PROPERTIES || [];
  for (var i = 0; i < styleProps.length; ++i) {
    var item = styleProps[i];
    var val = style[item.key];
    if (val !== undefined) {
      var stringVal = (val && typeof val === "object" && val.toString) ? val.toString() : val;
      var arr = [];
      for (var d = 0; d <= count; ++d) {
        arr.push(stringVal);
      }
      root[item.prop] = arr;
    }
  }
  saveConfiguration(root);
};

const applyStyleToDesktop = function(root, linkToggleChecked, desktopModelCount, style, deskIdx) {
  if (!style) {
    return;
  }
  if (linkToggleChecked) {
    applyStyleToAllDesktops(root, desktopModelCount, style);
    return;
  }
  var styleProps = root._STYLE_PROPERTIES || [];
  for (var i = 0; i < styleProps.length; ++i) {
    var item = styleProps[i];
    var val = style[item.key];
    if (val !== undefined) {
      var stringVal = (val && typeof val === "object" && val.toString) ? val.toString() : val;
      root[item.prop] = setAt(root[item.prop], deskIdx, stringVal);
    }
  }
  saveConfiguration(root);
};

const getClipboardText = function(clipboardHelper) {
  clipboardHelper.text = "";
  clipboardHelper.selectAll();
  clipboardHelper.paste();
  return clipboardHelper.text;
};

const parseStyleFromText = function(str) {
  if (!str || typeof str !== "string") {
    return null;
  }
  try {
    var obj = JSON.parse(str);
    if (obj && typeof obj === "object") {
      if (obj.type === "DesktopIndicatorStyle") {
        return obj;
      }
      if (obj.dateBackgroundColor !== undefined ||
          obj.dayNameColor !== undefined ||
          obj.desktopNumberBackgroundColor !== undefined ||
          obj.desktopNameColor !== undefined) {
        return obj;
      }
    }
  } catch (e) {}
  return null;
};

const checkClipboard = function(clipboardHelper, root) {
  var text = getClipboardText(clipboardHelper);
  root.hasValidClipboardContent = parseStyleFromText(text) !== null;
};

const copySelectedDesktopStyle = function(root, clipboardHelper, selectedDesktopNo) {
  var style = getDesktopStyle(root, selectedDesktopNo);
  clipboardHelper.text = JSON.stringify(style);
  clipboardHelper.selectAll();
  clipboardHelper.copy();
  root.lastCopiedStyle = style;
  checkClipboard(clipboardHelper, root);
};

const pasteDesktopStyle = function(root, clipboardHelper, selectedDesktopNo, lastCopiedStyle) {
  var text = getClipboardText(clipboardHelper);
  var style = parseStyleFromText(text) || lastCopiedStyle;
  if (style) {
    applyStyleToDesktop(root, false, 0, style, selectedDesktopNo);
  }
};

const openColor = function(colorDialog, target, current) {
  colorDialog.target = target;
  colorDialog.selectedColor = current;
  colorDialog.open();
};

const openFont = function(fontDialog, styleDialog, styleTargets, target, current, selectedDesktopNo) {
  fontDialog.target = target;
  fontDialog.selectedFamily = current;
  var styleTarget = target === "styleFont" ? styleDialog.target : target;
  var targetKey = styleTarget === "numberText" ? "desktopNumber" : styleTarget;
  var info = styleTargets[targetKey];
  fontDialog.previewText = info ? info.previewText() : String(selectedDesktopNo);
  fontDialog.open();
};

const rebuildDesktops = function(desktopBox, desktopModel, desktopInfo) {
  var previousIndex = desktopBox.currentIndex;
  desktopModel.clear();
  var ids = desktopInfo.desktopIds || [];
  var names = desktopInfo.desktopNames || [];
  var count = Math.max(desktopInfo.numberOfDesktops || 0,
      ids.length || 0, names.length || 0, 1);
  for (var i = 0; i < count; ++i) {
    var desktopName = (names && names[i])
        ? names[i] : qsTr("Desktop %1").arg(i + 1);
    desktopModel.append({name: desktopName, number: i + 1});
  }
  desktopBox.currentIndex = Math.min(Math.max(previousIndex, 0), count - 1);
};

const openStyle = function(styleDialog, root, styleTargets, selectedDesktopNo, target) {
  var targetKey = target === "numberText" ? "desktopNumber" : target;
  var info = styleTargets[targetKey];
  var deskIdx = selectedDesktopNo;
  styleDialog.target = target;
  styleDialog.title = info ? info.title : qsTr("Style");
  styleDialog.fontName = (ensureDesktopProperty(root, info.fontProp, deskIdx)) || (info ? info.defaultFont : "Sans Serif");
  styleDialog.selectedTextColor = (ensureDesktopProperty(root, info.colorProp, deskIdx)) || (info ? info.defaultColor : "#071169");
  styleDialog.scaleValue = Number((ensureDesktopProperty(root, info.scaleProp, deskIdx)) || 50);
  styleDialog.open();
};
