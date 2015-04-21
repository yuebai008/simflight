function lib = AddLqrControllersToLib(name, lib, p, xtraj, utraj, parameters, gains)
 
  Q = gains.Q;
  Qf = gains.Qf;
  R_values = gains.R_values;
  K_pd = gains.K_pd;
  K_pd_yaw = gains.K_pd_yaw;
  K_pd_aggressive_yaw = gains.K_pd_aggressive_yaw;


  for i = 1:length(R_values)
    R = diag([R_values(i)*ones(1,3)]);

    disp(['Computing TVLQR controller (R = ' num2str(R_values(i)) ')...']);
    lqr_controller = tvlqr(p, xtraj, utraj, Q, R, Qf);

    comments = sprintf('%s\n\n%s', name, [prettymat('Parameters', cell2mat(parameters), 3) ...
      prettymat('Q', Q, 5) prettymat('R', R)]);
    lib = lib.AddTrajectory(p, xtraj, utraj, lqr_controller, [name '-R-' num2str(R_values(i))], comments);

  end
  
  % now just use the K_pd's and build trajectories
  
  
  ktraj = ConstantTrajectory(-K_pd);
  affine_traj = ConstantTrajectory(zeros(3,1));

  lqrsys = struct();
  lqrsys.D = ktraj;
  lqrsys.y0 = affine_traj;
  
  lib = lib.AddTrajectory(p, xtraj, utraj, lqrsys, [name '-PD'], comments);
  
  ktraj = ConstantTrajectory(-K_pd_yaw);
  lqrsys = struct();
  lqrsys.D = ktraj;
  lqrsys.y0 = affine_traj;
  lib = lib.AddTrajectory(p, xtraj, utraj, lqrsys, [name '-PD-yaw'], comments);
  
  ktraj = ConstantTrajectory(-K_pd_aggressive_yaw);
  lqrsys = struct();
  lqrsys.D = ktraj;
  lqrsys.y0 = affine_traj;
  lib = lib.AddTrajectory(p, xtraj, utraj, lqrsys, [name '-PD-aggressive-yaw'], comments);
  
  
  disp('done');

end