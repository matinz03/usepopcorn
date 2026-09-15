/**
 * The one component every "nothing here" moment goes through, so an empty
 * search, a failed request and an empty list all get the same generous,
 * centred treatment instead of a bare line of text.
 */
export default function EmptyState({
  icon,
  title,
  hint,
  action,
  tone = "neutral",
}) {
  return (
    <div className={`empty empty--${tone}`} role={tone === "error" ? "alert" : undefined}>
      {icon && (
        <span className="empty__icon" aria-hidden="true">
          {icon}
        </span>
      )}
      <h2 className="empty__title">{title}</h2>
      {hint && <p className="empty__hint">{hint}</p>}
      {action && <div className="empty__action">{action}</div>}
    </div>
  );
}
