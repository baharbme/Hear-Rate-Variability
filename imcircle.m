function varargout=imrecanglecon(varargin)
%Same as imellipse, except the ellipse is constrained to be perfectly
%circular.
  H=drawrectangle(varargin{:},'PositionConstraintFcn',@recanglecon );
 
            
  if nargout
     varargout={H}; 
  end
            
  
 function newpos=recanglecon(pos)
 newpos=pos;
 newpos(3:4)=max(pos(3:4));