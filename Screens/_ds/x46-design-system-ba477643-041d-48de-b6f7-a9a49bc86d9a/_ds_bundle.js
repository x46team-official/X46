/* @ds-bundle: {"format":4,"namespace":"X46DesignSystem_ba4776","components":[{"name":"Alert","sourcePath":"components/feedback/Alert.jsx"},{"name":"Badge","sourcePath":"components/feedback/Badge.jsx"},{"name":"Button","sourcePath":"components/forms/Button.jsx"},{"name":"Checkbox","sourcePath":"components/forms/Checkbox.jsx"},{"name":"Input","sourcePath":"components/forms/Input.jsx"},{"name":"Radio","sourcePath":"components/forms/Radio.jsx"},{"name":"Select","sourcePath":"components/forms/Select.jsx"},{"name":"Switch","sourcePath":"components/forms/Switch.jsx"},{"name":"Card","sourcePath":"components/layout/Card.jsx"}],"sourceHashes":{"components/feedback/Alert.jsx":"e11817e4604a","components/feedback/Badge.jsx":"523dbe1ac091","components/forms/Button.jsx":"6339c656c883","components/forms/Checkbox.jsx":"85c674a04dad","components/forms/Input.jsx":"93ca0c3ad875","components/forms/Radio.jsx":"ad525e261c8e","components/forms/Select.jsx":"ae74abbaadef","components/forms/Switch.jsx":"d633315a9bac","components/layout/Card.jsx":"61f3b65b509f"},"inlinedExternals":[],"unexposedExports":[]} */

(() => {

const __ds_ns = (window.X46DesignSystem_ba4776 = window.X46DesignSystem_ba4776 || {});

const __ds_scope = {};

(__ds_ns.__errors = __ds_ns.__errors || []);

// components/feedback/Alert.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
function Alert(props) {
  const {
    children,
    variant = 'info',
    title,
    onClose,
    className = '',
    ...rest
  } = props;
  const baseStyles = {
    padding: '16px',
    borderRadius: 'var(--radius-lg)',
    border: '1px solid transparent',
    display: 'flex',
    gap: '12px',
    alignItems: 'flex-start'
  };
  const variantStyles = {
    info: {
      background: 'rgba(0, 153, 255, 0.05)',
      borderColor: 'rgba(0, 153, 255, 0.2)',
      color: 'var(--color-text-primary)'
    },
    success: {
      background: 'rgba(75, 191, 106, 0.05)',
      borderColor: 'rgba(75, 191, 106, 0.2)',
      color: 'var(--color-text-primary)'
    },
    warning: {
      background: 'rgba(245, 158, 11, 0.05)',
      borderColor: 'rgba(245, 158, 11, 0.2)',
      color: 'var(--color-text-primary)'
    },
    error: {
      background: 'rgba(239, 68, 68, 0.05)',
      borderColor: 'rgba(239, 68, 68, 0.2)',
      color: 'var(--color-text-primary)'
    }
  };
  const style = {
    ...baseStyles,
    ...variantStyles[variant]
  };
  const contentStyles = {
    flex: 1
  };
  const titleStyles = {
    fontWeight: 600,
    marginBottom: '4px',
    fontSize: '14px'
  };
  const closeStyles = {
    cursor: 'pointer',
    opacity: 0.6,
    transition: 'opacity var(--transition-fast)',
    background: 'none',
    border: 'none',
    padding: 0,
    fontSize: '18px',
    color: 'inherit'
  };
  return /*#__PURE__*/React.createElement("div", _extends({
    style: style,
    className: className
  }, rest), /*#__PURE__*/React.createElement("div", {
    style: contentStyles
  }, title && /*#__PURE__*/React.createElement("div", {
    style: titleStyles
  }, title), children), onClose && /*#__PURE__*/React.createElement("button", {
    style: closeStyles,
    onClick: onClose
  }, "\xD7"));
}
Object.assign(__ds_scope, { Alert });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/feedback/Alert.jsx", error: String((e && e.message) || e) }); }

// components/feedback/Badge.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
function Badge(props) {
  const {
    children,
    variant = 'default',
    size = 'md',
    className = '',
    ...rest
  } = props;
  const baseStyles = {
    display: 'inline-flex',
    alignItems: 'center',
    justifyContent: 'center',
    fontWeight: 600,
    borderRadius: 'var(--radius-full)',
    whiteSpace: 'nowrap'
  };
  const sizeStyles = {
    sm: {
      fontSize: '12px',
      padding: '4px 8px'
    },
    md: {
      fontSize: '14px',
      padding: '6px 12px'
    },
    lg: {
      fontSize: '16px',
      padding: '8px 16px'
    }
  };
  const variantStyles = {
    default: {
      background: 'var(--color-gray-200)',
      color: 'var(--color-text-primary)'
    },
    primary: {
      background: 'var(--color-primary-bright)',
      color: 'var(--color-text-inverse)'
    },
    success: {
      background: 'var(--color-success)',
      color: 'var(--color-text-inverse)'
    },
    warning: {
      background: 'var(--color-warning)',
      color: 'var(--color-text-inverse)'
    },
    error: {
      background: 'var(--color-error)',
      color: 'var(--color-text-inverse)'
    }
  };
  const style = {
    ...baseStyles,
    ...sizeStyles[size],
    ...variantStyles[variant]
  };
  return /*#__PURE__*/React.createElement("span", _extends({
    style: style,
    className: className
  }, rest), children);
}
Object.assign(__ds_scope, { Badge });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/feedback/Badge.jsx", error: String((e && e.message) || e) }); }

// components/forms/Button.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
function Button(props) {
  const {
    children,
    variant = 'primary',
    size = 'md',
    disabled = false,
    type = 'button',
    onClick,
    className = '',
    ...rest
  } = props;
  const baseStyles = {
    fontFamily: 'var(--font-sans)',
    fontWeight: 600,
    border: 'none',
    borderRadius: 'var(--radius-base)',
    cursor: disabled ? 'not-allowed' : 'pointer',
    transition: 'all var(--transition-base)',
    display: 'inline-flex',
    alignItems: 'center',
    justifyContent: 'center',
    gap: '8px',
    whiteSpace: 'nowrap'
  };
  const sizeStyles = {
    sm: {
      padding: '8px 12px',
      fontSize: '14px'
    },
    md: {
      padding: '10px 16px',
      fontSize: '16px'
    },
    lg: {
      padding: '12px 20px',
      fontSize: '16px'
    }
  };
  const variantStyles = {
    primary: {
      background: 'var(--color-primary-bright)',
      color: 'var(--color-text-inverse)'
    },
    secondary: {
      background: 'var(--color-gray-200)',
      color: 'var(--color-text-primary)'
    },
    ghost: {
      background: 'transparent',
      color: 'var(--color-primary-bright)',
      border: '1px solid var(--color-border-base)'
    },
    danger: {
      background: 'var(--color-error)',
      color: 'var(--color-text-inverse)'
    }
  };
  const disabledStyles = disabled ? {
    opacity: 0.6,
    pointerEvents: 'none'
  } : {};
  const style = {
    ...baseStyles,
    ...sizeStyles[size],
    ...variantStyles[variant],
    ...disabledStyles
  };
  return /*#__PURE__*/React.createElement("button", _extends({
    type: type,
    onClick: onClick,
    disabled: disabled,
    style: style,
    className: className
  }, rest), children);
}
Object.assign(__ds_scope, { Button });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/forms/Button.jsx", error: String((e && e.message) || e) }); }

// components/forms/Checkbox.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
function Checkbox(props) {
  const {
    checked = false,
    onChange,
    disabled = false,
    label,
    className = '',
    ...rest
  } = props;
  const containerStyles = {
    display: 'flex',
    alignItems: 'center',
    gap: '8px',
    cursor: disabled ? 'not-allowed' : 'pointer'
  };
  const checkboxStyles = {
    width: '20px',
    height: '20px',
    borderRadius: 'var(--radius-sm)',
    border: '2px solid var(--color-border-base)',
    cursor: disabled ? 'not-allowed' : 'pointer',
    transition: 'all var(--transition-fast)',
    backgroundColor: checked ? 'var(--color-primary-bright)' : 'var(--color-surface-bg)',
    borderColor: checked ? 'var(--color-primary-bright)' : 'var(--color-border-base)',
    opacity: disabled ? 0.6 : 1,
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center'
  };
  const labelStyles = {
    fontSize: '16px',
    color: disabled ? 'var(--color-text-tertiary)' : 'var(--color-text-primary)',
    cursor: disabled ? 'not-allowed' : 'pointer'
  };
  return /*#__PURE__*/React.createElement("label", {
    style: containerStyles,
    className: className
  }, /*#__PURE__*/React.createElement("input", _extends({
    type: "checkbox",
    checked: checked,
    onChange: onChange,
    disabled: disabled,
    style: {
      display: 'none'
    }
  }, rest)), /*#__PURE__*/React.createElement("div", {
    style: checkboxStyles
  }, checked && /*#__PURE__*/React.createElement("span", {
    style: {
      color: 'white',
      fontSize: '14px',
      fontWeight: 'bold'
    }
  }, "\u2713")), label && /*#__PURE__*/React.createElement("span", {
    style: labelStyles
  }, label));
}
Object.assign(__ds_scope, { Checkbox });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/forms/Checkbox.jsx", error: String((e && e.message) || e) }); }

// components/forms/Input.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
function Input(props) {
  const {
    type = 'text',
    placeholder = '',
    value,
    onChange,
    disabled = false,
    error = false,
    size = 'md',
    className = '',
    ...rest
  } = props;
  const baseStyles = {
    fontFamily: 'var(--font-sans)',
    fontSize: '16px',
    border: '1px solid var(--color-border-base)',
    borderRadius: 'var(--radius-base)',
    padding: size === 'sm' ? '8px 12px' : size === 'lg' ? '12px 16px' : '10px 14px',
    transition: 'all var(--transition-base)',
    width: '100%',
    boxSizing: 'border-box',
    color: 'var(--color-text-primary)',
    background: 'var(--color-surface-bg)'
  };
  const errorStyles = error ? {
    borderColor: 'var(--color-error)'
  } : {};
  const disabledStyles = disabled ? {
    background: 'var(--color-gray-100)',
    color: 'var(--color-text-tertiary)',
    cursor: 'not-allowed'
  } : {};
  const style = {
    ...baseStyles,
    ...errorStyles,
    ...disabledStyles
  };
  return /*#__PURE__*/React.createElement("input", _extends({
    type: type,
    placeholder: placeholder,
    value: value,
    onChange: onChange,
    disabled: disabled,
    style: style,
    className: className
  }, rest));
}
Object.assign(__ds_scope, { Input });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/forms/Input.jsx", error: String((e && e.message) || e) }); }

// components/forms/Radio.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
function Radio(props) {
  const {
    name,
    value,
    checked = false,
    onChange,
    disabled = false,
    label,
    className = '',
    ...rest
  } = props;
  const containerStyles = {
    display: 'flex',
    alignItems: 'center',
    gap: '8px',
    cursor: disabled ? 'not-allowed' : 'pointer'
  };
  const radioStyles = {
    width: '20px',
    height: '20px',
    borderRadius: '50%',
    border: '2px solid var(--color-border-base)',
    cursor: disabled ? 'not-allowed' : 'pointer',
    transition: 'all var(--transition-fast)',
    backgroundColor: 'var(--color-surface-bg)',
    borderColor: checked ? 'var(--color-primary-bright)' : 'var(--color-border-base)',
    opacity: disabled ? 0.6 : 1,
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    position: 'relative'
  };
  const innerDot = checked ? {
    width: '8px',
    height: '8px',
    borderRadius: '50%',
    backgroundColor: 'var(--color-primary-bright)'
  } : null;
  const labelStyles = {
    fontSize: '16px',
    color: disabled ? 'var(--color-text-tertiary)' : 'var(--color-text-primary)',
    cursor: disabled ? 'not-allowed' : 'pointer'
  };
  return /*#__PURE__*/React.createElement("label", {
    style: containerStyles,
    className: className
  }, /*#__PURE__*/React.createElement("input", _extends({
    type: "radio",
    name: name,
    value: value,
    checked: checked,
    onChange: onChange,
    disabled: disabled,
    style: {
      display: 'none'
    }
  }, rest)), /*#__PURE__*/React.createElement("div", {
    style: radioStyles
  }, innerDot && /*#__PURE__*/React.createElement("div", {
    style: innerDot
  })), label && /*#__PURE__*/React.createElement("span", {
    style: labelStyles
  }, label));
}
Object.assign(__ds_scope, { Radio });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/forms/Radio.jsx", error: String((e && e.message) || e) }); }

// components/forms/Select.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
function Select(props) {
  const {
    options = [],
    value,
    onChange,
    placeholder = 'Select an option',
    disabled = false,
    size = 'md',
    className = '',
    ...rest
  } = props;
  const baseStyles = {
    fontFamily: 'var(--font-sans)',
    fontSize: '16px',
    border: '1px solid var(--color-border-base)',
    borderRadius: 'var(--radius-base)',
    padding: size === 'sm' ? '8px 12px' : size === 'lg' ? '12px 16px' : '10px 14px',
    transition: 'all var(--transition-base)',
    width: '100%',
    boxSizing: 'border-box',
    color: 'var(--color-text-primary)',
    background: 'var(--color-surface-bg)',
    cursor: disabled ? 'not-allowed' : 'pointer'
  };
  const disabledStyles = disabled ? {
    background: 'var(--color-gray-100)',
    color: 'var(--color-text-tertiary)',
    cursor: 'not-allowed',
    opacity: 0.6
  } : {};
  const style = {
    ...baseStyles,
    ...disabledStyles
  };
  return /*#__PURE__*/React.createElement("select", _extends({
    value: value || '',
    onChange: onChange,
    disabled: disabled,
    style: style,
    className: className
  }, rest), /*#__PURE__*/React.createElement("option", {
    value: ""
  }, placeholder), options.map(opt => /*#__PURE__*/React.createElement("option", {
    key: opt.value,
    value: opt.value
  }, opt.label)));
}
Object.assign(__ds_scope, { Select });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/forms/Select.jsx", error: String((e && e.message) || e) }); }

// components/forms/Switch.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
function Switch(props) {
  const {
    checked = false,
    onChange,
    disabled = false,
    label,
    className = '',
    ...rest
  } = props;
  const containerStyles = {
    display: 'flex',
    alignItems: 'center',
    gap: '12px',
    cursor: disabled ? 'not-allowed' : 'pointer'
  };
  const switchStyles = {
    width: '44px',
    height: '24px',
    borderRadius: '12px',
    backgroundColor: checked ? 'var(--color-primary-bright)' : 'var(--color-gray-300)',
    transition: 'background-color var(--transition-fast)',
    cursor: disabled ? 'not-allowed' : 'pointer',
    border: 'none',
    padding: '2px',
    display: 'flex',
    alignItems: 'center',
    position: 'relative',
    opacity: disabled ? 0.6 : 1
  };
  const knobStyles = {
    width: '20px',
    height: '20px',
    borderRadius: '50%',
    backgroundColor: 'white',
    transition: 'transform var(--transition-fast)',
    transform: checked ? 'translateX(20px)' : 'translateX(0)'
  };
  const labelStyles = {
    fontSize: '16px',
    color: disabled ? 'var(--color-text-tertiary)' : 'var(--color-text-primary)',
    cursor: disabled ? 'not-allowed' : 'pointer'
  };
  return /*#__PURE__*/React.createElement("label", {
    style: containerStyles,
    className: className
  }, /*#__PURE__*/React.createElement("input", _extends({
    type: "checkbox",
    checked: checked,
    onChange: onChange,
    disabled: disabled,
    style: {
      display: 'none'
    }
  }, rest)), /*#__PURE__*/React.createElement("div", {
    style: switchStyles
  }, /*#__PURE__*/React.createElement("div", {
    style: knobStyles
  })), label && /*#__PURE__*/React.createElement("span", {
    style: labelStyles
  }, label));
}
Object.assign(__ds_scope, { Switch });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/forms/Switch.jsx", error: String((e && e.message) || e) }); }

// components/layout/Card.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
function Card(props) {
  const {
    children,
    variant = 'default',
    interactive = false,
    className = '',
    onClick,
    ...rest
  } = props;
  const baseStyles = {
    background: 'var(--color-surface-bg)',
    border: '1px solid var(--color-border-light)',
    borderRadius: 'var(--radius-lg)',
    padding: '20px',
    boxShadow: 'var(--shadow-sm)',
    transition: 'all var(--transition-base)'
  };
  const variantStyles = {
    default: {},
    elevated: {
      boxShadow: 'var(--shadow-md)',
      border: 'none'
    },
    outlined: {
      boxShadow: 'none',
      background: 'var(--color-gray-50)'
    }
  };
  const interactiveStyles = interactive ? {
    cursor: 'pointer'
  } : {};
  const style = {
    ...baseStyles,
    ...variantStyles[variant],
    ...interactiveStyles
  };
  const Tag = interactive ? 'button' : 'div';
  return /*#__PURE__*/React.createElement(Tag, _extends({
    style: style,
    className: className,
    onClick: onClick
  }, interactive ? {
    type: 'button'
  } : {}, rest), children);
}
Object.assign(__ds_scope, { Card });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/layout/Card.jsx", error: String((e && e.message) || e) }); }

__ds_ns.Alert = __ds_scope.Alert;

__ds_ns.Badge = __ds_scope.Badge;

__ds_ns.Button = __ds_scope.Button;

__ds_ns.Checkbox = __ds_scope.Checkbox;

__ds_ns.Input = __ds_scope.Input;

__ds_ns.Radio = __ds_scope.Radio;

__ds_ns.Select = __ds_scope.Select;

__ds_ns.Switch = __ds_scope.Switch;

__ds_ns.Card = __ds_scope.Card;

})();
